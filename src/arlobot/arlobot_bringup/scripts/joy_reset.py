#!/usr/bin/env python

import rospy

from sensor_msgs.msg import Joy
from std_msgs.msg import Bool

# Init ROS node
rospy.init_node('arloreset_joy')


def joyCB(j):
  global clock
  if clock < 3:
    return
  if j.buttons[5] == 1:
    r = Bool()
    r.data = True
    reset_pub.publish(r)
    clock = 0


# Publishers
reset_pub = rospy.Publisher("arlobot/reset_motorBoard", Bool, queue_size=10)

# Subscribers
joy_sub = rospy.Subscriber('joy', Joy, joyCB)

freq = 1
rate = rospy.Rate(freq)

global clock
clock = 0

while not rospy.is_shutdown():
  clock = clock + 1
  rate.sleep()
