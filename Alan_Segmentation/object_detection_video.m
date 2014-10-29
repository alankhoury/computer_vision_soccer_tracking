fin = '..\test_videos\goal2.mp4'; %input File name to be changed
fout = 'goal2.avi'; %output File name to be changed

%get the File info
fileinfo = aviinfo(fin);
%get the number of Frames
nframes = fileinfo.NumFrames;

aviobj = avifile(fout, 'compression', 'none', 'fps',fileinfo.FramesPerSecond);

for i = 1:(nframes) %You may need to limit the nFrames, may result in a large file size
%Read frames from input video
mov_in = aviread(fin,i);
im_in = frame2im(mov_in);

%remove audience ein each frame



%Write frames to output video
frm = im2frame(im_out);
aviobj = addframe(aviobj,frm);

i %Just to display frame number you can ommit
end;

%Don't forget to close output file
aviobj = close(aviobj);
return;