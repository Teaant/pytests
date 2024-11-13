import serial  
import struct

import csv  

from enum import Enum  

class Status(Enum):  
    BEACON = 0x8841  
    DATA = 0x8841|(1<<7)  
    MAC_CMD = 0x8841|(3<<7)
    ACK_FRAME = 0x8841|(2<<7)

class Frame(Enum):  
    UWB_Ranging_Poll = 0
    UWB_Ranging_Resp = 1
    UWB_Ranging_Final = 2
    UWB_Ranging_Ack = 3
    UWB_App_Data = 4
    UWB_Cmd_Req = 0x11
    UWB_Cmd_Modify = 0x12
    UWB_Cmd_Release = 0x13
	

# 计数器频率  
frequency = 499.2 * 128e6  # 499.2 * 128 MHz  
# 每个计数的时间（秒）  
time_per_count = 1 / frequency  # 每个计数的时间（秒）  


def count_to_milliseconds(count):  
    # 将计数值转换为毫秒  
    return count * time_per_count * 100  # 转换为毫秒  

def write_to_csv(file_name, data):  
    with open(file_name, mode='a', newline='') as csv_file:  
        writer = csv.writer(csv_file)  
        writer.writerow(data)  # 写入一行数据

def receive_data_from_serial(port='COM7', baudrate=115200, timeout=None):  
    try:  
        # 打开串口  
        # 设置超时时间为None这样子就不太会出现超时了 ！ 这可真是太棒了 ！
        with serial.Serial(port, baudrate, timeout=timeout) as ser:  
            print(f"打开串口 {port}, 波特率 {baudrate}")  
            last_value = 0

            with open("record.csv", mode='w', newline='') as csv_file:  
                writer = csv.writer(csv_file)  
                writer.writerow(['timestamp', 'frame_type', 'src_addr', 'dist_addr'])  # CSV 文件的标题 

            while True:  
                # 读取一行字节流  
                line = ser.read_until(b'\r\n') # 读取直到换行符  
                if line:
                    # 处理接收到的字节流  
                    # print(f"接收到的行: {line.decode('utf-8').strip()}")  # 解码为字符串并去掉首尾空格                      
                    # 前面8个字节
                    hex_repr = line.hex()  
                    print(f"长度= {len(line)}, 字节流的十六进制表示: {hex_repr}")  
                    if (len(line) >= 8+13) and line[5] == 0 and line[6] == 0 and line[7] == 0:
                        timestamp_bytes = line[:8]  
                        # print(timestamp_bytes[0])
                        timestamp = struct.unpack('<Q', timestamp_bytes)[0]  # '<Q'表示小端字节序的无符号长整型
                        time_ms =round(timestamp/499.2/128/1000, 2)
                        print(time_ms)
                        package = '\n'
                        if line[8+1] == 0x88 and line[8] == 0x41:
                            package = 'b'
                        elif (line[8+1] == 0x88 and line[8] == 0xc1)   or (line[8+1] == 0x89 and line[8] == 0xc1):
                            ranging_type = line[8+9]
                            if ranging_type == 0:
                                package = 'p'
                            elif ranging_type == 1:
                                package = 'r'
                                #哪里来的这个啊，不是这边就是说是它自己发送的？
                            elif ranging_type == 2:
                                package = 'f'
                            elif ranging_type == 0x11:   
                                package = 'j'
                            elif ranging_type == 0x12:
                                package = 'm'
                            else :
                                package = 'd'
                        else :
                            package = 'a'
                        print(package)   
                        # 把数据写入文件用于分析
                        src = (line[8+8]<<8)|line[8+7]
                        dist = (line[8+6]<<8)|line[8+5]
                        # 时间， 数据包类型， 源地址， 目的地址
                        write_to_csv("record.csv", [timestamp, package, src, dist])                
                        
    except serial.SerialException as e:  
        print(f"串口异常: {e}")  
    except KeyboardInterrupt:  
        print("接收中断，程序终止。")  

if __name__ == '__main__':  
    receive_data_from_serial('COM7', 115200)  # 根据需要修改串口和波特率