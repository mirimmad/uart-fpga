import serial
import threading
import time


SERIAL_PORT = '/dev/ttyUSB0'  # Replace with your serial port
BAUD_RATE = 9600
TIMEOUT = 1

# Initialize the serial connection
try:
	ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=TIMEOUT)
except:
	print(f"Could not connect to {SERIAL_PORT}")
	exit()

def listen_to_serial():
    """Thread function to continuously listen to serial data."""
    while True:
        if ser.in_waiting > 0:
        
            #data = ser.readline().decode('utf-8').strip()
            #data = ser.read(1)
            byte_data = ser.read(1)
            data = int.from_bytes(byte_data, byteorder='big')
            if data:
                print(f"Received: {data}")

def send_user_input():
    """Thread function to send user input to the serial port."""
    while True:
        user_input = input("Enter data to send: ")
        b = int(user_input)
        if user_input:
        #ser.write(user_input.encode('utf-8') + b'\n')
         ser.write(b.to_bytes(1, byteorder='big'))

def main():
    # Create and start threads
    listener_thread = threading.Thread(target=listen_to_serial, daemon=True)
    sender_thread = threading.Thread(target=send_user_input, daemon=True)
    
    listener_thread.start()
    sender_thread.start()

    # Keep the main program running
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Program terminated.")
    finally:
        ser.close()

if __name__ == "__main__":
    main()

