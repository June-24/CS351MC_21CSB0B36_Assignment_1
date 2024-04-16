# Open the trace file for reading
with open("/home/junaid/Documents/MC/Assignment 1/q2/21CSB0B36_Q2.tr", "r") as tracefile:
    # Initialize a counter for dropped packets
    dropped_packets = 0
    
    # Read each line in the trace file
    for line in tracefile:
        # Check if the line indicates a dropped packet (starts with 'd')
        if line.startswith('d'):
            # Increment the counter for dropped packets
            dropped_packets += 1

# Print the total number of dropped packets
print("Total number of dropped packets:", dropped_packets)
