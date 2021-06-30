



# def main():
#     # Access all the topics and their associated port number
#     port_names = msg.PORTLIST.TOPICS.DESCRIPTOR.values_by_name.keys()

#     # Creating subscribers and poller
#     ctx = zmq.Context()
#     subs = []
#     poller = zmq.Poller()
#     for name in port_names[1:]: 
#         port_number = msg.PORTLIST.TOPICS.Value(name)
#         sub = messaging.create_sub(ctx,port_number)
#         subs.append(sub)
#         poller.register(sub, zmq.POLLIN)

#     data = []
#     # Main loop for logging data 
#     f = open("out.bin", "wb")
#     try:
#         while True: 
#             socks = poller.poll(0.01)
#             for s in socks:
#                 # non blocking 
#                 data = s[0].recv(zmq.DONTWAIT)
#                 print(len(data))
#                 f.write(data + b'//')
#             # Writing to file 

#     except KeyboardInterrupt:
#         f.close()
#         print("interrupted!")


# if __name__ == "__main__":
#     main()