#!/usr/bin/env python 
 
import rospy 
import sys
import csv 
import datetime 
 
from std_msgs.msg import String 
 
# Class 
class CSV_log(object): 
  def __init__(self): 
    rospy.init_node('log_data')
    self.rate = rospy.Rate(1) 
    if len(sys.argv) > 0:
      self.file_name = str(sys.argv[1])
    else:
      self.file_name = 'log.csv'
    
    # Subcribers 
    serial_sub = rospy.Subscriber('serial', String, self.SerialCB)    
  
    self.csvfile = open(self.file_name, 'w') 
    fieldnames = ['timestamp', 'x', 'y', 'theta', 'V', 'Omega', 'Left_count', 'Right_count'] 
    self.writer = csv.DictWriter(csvfile, fieldnames=fieldnames) 
    self.writer.writeheader() 
  
  def Running(self):
    while not rospy.is_shutdown():
      self.rate.sleep()
  
  def Stop(self):
    self.csvfile.close()
            
  def SerialCB(self, s): 
    t = datetime.datetime.now().time() 
    if len(s.data) > 0:  
      line_parts = s.data.split('\t') 
      try: 
        x = float(line_parts[1]) 
        y = float(line_parts[2]) 
        theta = float(line_parts[3]) 
        vel = float(line_parts[5]) 
        omega = float(line_parts[6]) 
        l_count = int(line_parts[7]) 
        r_count = int(line_parts[8]) 
        self.writer.writerow({'timestamp': t, 'x': x, 'y': y, 'theta': theta, 'V': vel, 'Omega': omega, 'Left_count': l_count, 'Right_count': r_count}) 
      except: 
        return 

if __name__ == '__main__':  
  log = CSV_log()
  rospy.on_shutdown(log.Stop)
  try:
    log.Running()
  except rospy.ROSInterruptException:
    log.Stop()
    
