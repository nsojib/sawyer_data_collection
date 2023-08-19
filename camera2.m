close all;

cam=webcam(1);
while 1

    img= cam.snapshot();
    imshow(img)

end
