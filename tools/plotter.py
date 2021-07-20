# Import libraries
import sys 
sys.path.append("..")
import numpy as np 
from pyqtgraph.Qt import QtGui, QtCore
import pyqtgraph as pg
import pyqtgraph.opengl as gl
import zmq 
import pymessaging.message_pb2 as msg
from pymessaging import messaging
import time

def make_cube():
    vertexes = np.array([[1, 0, 0], #0
                     [0, 0, 0], #1
                     [0, 1, 0], #2
                     [0, 0, 1], #3
                     [1, 1, 0], #4
                     [1, 1, 1], #5
                     [0, 1, 1], #6
                     [1, 0, 1]])#7
    
    faces = np.array([[1,0,7], [1,3,7],
                  [1,2,4], [1,0,4],
                  [1,2,6], [1,3,6],
                  [0,4,5], [0,7,5],
                  [2,4,5], [2,6,5],
                  [3,6,5], [3,7,5]])
    
    colors = np.array([1,0,0,1] for in range(12))
    cube = gl.GLMeshItem(vertexes=vertices, faces=faces, faceColors=colors, drawEdges=True, edgeColor=(0,0,0,1))
    return cube 

def update_plot(plot, l, value, ptr):
    l[:-1] = l[1:]
    l[-1] = float(value)
    plot.setData(l)
    plot.setPos(ptr,0)
    return

### MAIN PROGRAM #####    
try :
    # Initializing plots
    app = QtGui.QApplication([])            # you MUST do this once (initialize things)
    win = pg.GraphicsWindow(title="Signal from serial port") # creates a window
    p = win.addPlot(title="Realtime plot")  # creates empty space for the plot in the window
    vx = p.plot()                        # create an empty "plot" (a curve to plot)
    vy = p.plot(pen="r") 
    vz = p.plot(pen="w")

    windowWidth = 500                       # width of the window displaying the curve
    # Xm = linspace(0,0,windowWidth)          # create array that will contain the relevant time series     
    ptr = -windowWidth                      # set first x position

    vx_list = np.linspace(0,0,windowWidth)
    vy_list = np.linspace(0,0,windowWidth)
    vz_list = np.linspace(0,0,windowWidth)

    ctx = zmq.Context()
    poller = zmq.Poller() 
    ekf_sub = messaging.create_sub(ctx, "5003", host="192.168.3.123")
    poller.register(ekf_sub, zmq.POLLIN)
    ekf_msg = msg.EKF_msg()

    dt = 0.01
    t = time.time()
    while True: 
        socks = dict(poller.poll())
        # Update plots 
        if ekf_sub in socks.keys() and socks[ekf_sub] == zmq.POLLIN:
            if time.time() - t > dt:  
                data = ekf_sub.recv(zmq.DONTWAIT)
                ekf_msg.ParseFromString(data)
                ptr += 1 
                update_plot(vx, vx_list, ekf_msg.velocity.x, ptr)
                update_plot(vy, vy_list, ekf_msg.velocity.y, ptr) 
                update_plot(vz, vz_list, ekf_msg.velocity.z, ptr)
                t = time.time()

            app.processEvents()
        
except KeyboardInterrupt:
    app.quit()