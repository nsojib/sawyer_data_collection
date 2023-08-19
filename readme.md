### Sawyer Robot

1. Connect with the same lab network

2. Matlab
```matlab
setenv('ROS_MASTER_URI', 'http://192.168.1.10:11311')
setenv('ROS_IP', '192.168.1.30')
```

* 192.168.1.10 = sawyer robot IP
* 192.168.1.30 = this computer IP

### Docker
```
pull docker docker pull pac48/sawyer_demo
```

### run docker to enable robot sdk and gripper

```
sudo docker run --privileged -it --net=host pac48/sawyer_demo:latest bash
```

```
export ROS_MASTER_URI=http://192.168.1.10:11311
export ROS_IP=192.168.1.30
source devel/setup.bash
```

```
rosrun intera_interface enable_robot.py -e
```

```
rosrun intera_examples gripper_keyboard.py
<esc>
```

```
rosrun gripper gripper_listener.py
```


### joystick
another terminal
```
cd /home/sawyer_ws/src/sawyerDemo/sawyer_launch/launch
roslaunch sawyer.launch
```
