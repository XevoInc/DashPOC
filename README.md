# DashPOC
POC for mobile dash recognition

For the DashPOC project, you will need to install Git LFS. (https://git-lfs.github.com). Once installed, after the repo is cloned, run 'git lfs pull' from a command line to sync large files.

abbyy projecy:
This project uses the ABBYY OCR framework to do real-time text recognition and OCR. Tapping the search button and enter a string to search. Once the string is located, it will place a rd box around the string. That red box is selectable and will open a yahoo search for the text string searched.

DashPOC project:
View 1: The project uses Computer Vision (CV) and A Machine Learning (ML) model to perform real time analysis of ojects the camera sees
View 2: This uses CV to detect Text. Characters are shown with a green box and sentences are seen with a red box.

DashPOC2 project:
This project uses CV to track the display of an iPad. When there is a good rectangle hightlighted tap the screen to overlay a car dash. The CV will continue to track the iPad display and adjust the overlay over the dash as iPhone moves around freely.

SCNKitPOC project:
This project uses Augemented Reality (AR) , SceneKit and CV. The CV tracks the iPad display with a rectangle. Tapping the screen will place 3D dash overlay in front of the iPad display. The 3D dash will be mainted by AR in 3D space as the iPhone moves around freely.

SKKitDashPOC project:
This project uses AR and SpriteKit. It provides a bounding box to place over the iPad display. Once placed correctly, tapping the xcreen will place a 2D dash overlay on top of the iPad display. This 2D overlay will be mainedtained by AR in 3D space as the iPhone moves aroung freely. Tapping the screen will toggle the dash overlay on and off. The Gas, oil and seat belt indicators are all selectable and will open a yahoo search.

