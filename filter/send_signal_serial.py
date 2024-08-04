import threading
import serial
import time
import matplotlib.pyplot as plt
import numpy as np


SERIAL_PORT = '/dev/ttyUSB0'  # Change this to your serial port
BAUD_RATE = 9600


FILE_NAME = 'sine_samples.txt'
RECEIVED_FILE_NAME = 'received_signal.txt'


received_data = []
data_lock = threading.Lock()
samples_to_send = 1000  # Number of samples to send


def send_data(serial_conn):
    with open(FILE_NAME, 'r') as file:
        count = 0
        for line in file:
            if count >= samples_to_send:
                break
            try:
                # Read and send each integer value
                value = int(line.strip())
                if 0 <= value <= 255:
                    serial_conn.write(value.to_bytes(1, byteorder='big'))
                    count += 1
                    time.sleep(0.01)  # Sleep to simulate sending delay
                else:
                    print(f"Value {value} out of range, skipping.")
            except ValueError:
                print(f"Invalid value in file: {line.strip()}")

# Thread for receiving data
def receive_data(serial_conn):
    global received_data
    while len(received_data) < samples_to_send:
        if serial_conn.in_waiting > 0:
            byte = serial_conn.read(1)
            value = int.from_bytes(byte, byteorder='big')
            with data_lock:
                received_data.append(value)
            l = len(received_data) 
            print(f"{l} Received: {value}")


def main():
    
    with serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1) as ser:
        
        sender_thread = threading.Thread(target=send_data, args=(ser,))
        receiver_thread = threading.Thread(target=receive_data, args=(ser,))
        
        sender_thread.start()
        receiver_thread.start()

        # Wait for both threads to complete
        sender_thread.join()
        receiver_thread.join()

    # Save received data to a file for later use
    with open(RECEIVED_FILE_NAME, 'w') as file:
        for value in received_data:
            file.write(f"{value}\n")

    # Load the original signal
    original_signal = np.loadtxt(FILE_NAME, dtype=int)
    mx = np.max(original_signal)
    mn = np.min(original_signal)
    original_signal_scaled = np.array(original_signal) / 255 * (mx - mn) + mn
    
    # Scale received data back to the original amplitude range
    received_signal_scaled = np.array(received_data) / 255 * (mx - mn) + mn

    # Generate plot
    x = np.linspace(0, 1, samples_to_send)

    plt.figure(figsize=(12, 12))

    # Plot the signal sent via UART (original signal)
    plt.subplot(2, 1, 1)
    plt.plot(x, original_signal_scaled, label='Signal Sent via UART')
   # plt.xlabel('Time [s]')
    plt.ylabel('Amplitude')
    plt.title('Signal Sent via UART')
    plt.grid(True)
    plt.legend()

    # Plot the signal received from FPGA
    plt.subplot(2, 1, 2)
    plt.plot(x[:len(received_signal_scaled)], received_signal_scaled, label='Signal Received from FPGA', color='orange')
    #plt.xlabel('Time [s]')
    plt.ylabel('Amplitude')
    plt.title('Signal Received from FPGA')
    plt.grid(True)
    plt.legend()

    plt.tight_layout()
    plt.show()

if __name__ == '__main__':
    main()

