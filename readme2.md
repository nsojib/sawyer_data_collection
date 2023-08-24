### installation: 
* install rl from source
* inside sawyer_robot_ros2/src
* git clone git@github.com:AssistiveRoboticsUNH/sawyer_robot_ros2.git
* colcon build
* source install/setup.bash

### run:
```
cd /home/ns/docker/sawyer-noetic
docker compose up
```
* run teleop publisher.


```
cd ~/sawyer_robot_ros2/
source install/setup.bash
ros2 run joy joy_node
ros2 topic echo /joy  (should show all 0s)
```

* run teleop script
```
cd ~/sawyer_robot_ros2/
source install/setup.bash
cd src/teleop_script
(if error: LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/)
python3 teleop.py

 

ros2 topic echo /robot/joint_states  (if couldn't determine topic, then run pub_dbg.py then run this command again)


```
 