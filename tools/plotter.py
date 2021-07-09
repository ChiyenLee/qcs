# Import libraries
import sys 
sys.path.append("..")
from numpy import *
from pyqtgraph.Qt import QtGui, QtCore
import pyqtgraph as pg
import zmq 
import pymessaging.message_pb2 as msg
from pymessaging import messaging

def update_plot(plot, l, value, ptr):
    l[:-1] = l[1:]
    l[-1] = float(value)
    plot.setData(l)
    plot.setPos(ptr,0)
    return

### MAIN PROGRAM #####    
# this is a brutal infinite loop calling your realtime data plot
try :
    app = QtGui.QApplication([])            # you MUST do this once (initialize things)
    win = pg.GraphicsWindow(title="Signal from serial port") # creates a window
    p = win.addPlot(title="Realtime plot")  # creates empty space for the plot in the window
    qx = p.plot()                        # create an empty "plot" (a curve to plot)
    qy = p.plot(pen="r") 
    qz = p.plot(pen="w")
    qw = p.plot(pen="c")

    windowWidth = 500                       # width of the window displaying the curve
    Xm = linspace(0,0,windowWidth)          # create array that will contain the relevant time series     
    ptr = -windowWidth                      # set first x position

    qx_list = linspace(0,0,windowWidth)
    qy_list = linspace(0,0,windowWidth)
    qz_list = linspace(0,0,windowWidth)
    qw_list = linspace(0,0,windowWidth)

    ctx = zmq.Context()
    poller = zmq.Poller() 
    vicon_sub = messaging.create_sub(ctx, "5000")
    poller.register(vicon_sub, zmq.POLLIN)
    vicon = msg.Vicon()
    while True: 
        socks = dict(poller.poll())
        if vicon_sub in socks.keys() and socks[vicon_sub] == zmq.POLLIN:
            data = vicon_sub.recv(zmq.DONTWAIT)
            vicon.ParseFromString(data)
            ptr += 1 
            update_plot(qx, qx_list, vicon.quaternion.x, ptr)
            update_plot(qy, qy_list, vicon.quaternion.y, ptr) 
            update_plot(qz, qz_list, vicon.quaternion.z, ptr)
            update_plot(qw, qw_list, vicon.quaternion.w, ptr)

            app.processEvents()
        
except KeyboardInterrupt:
    app.quit()