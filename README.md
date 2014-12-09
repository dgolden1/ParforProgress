Class to monitor progress of parfor loop

Create an empty file in the temporary directory for each iteration and count the files to determine which iteration we're on

USAGE:

```matlab
pp = ParforProgress;
parfor kk = 1:100
  DO_SOMETHING;
  iteration_number = step(pp, kk);
  fprintf('Finished iteration %d of %d\n', iteration_number, kk);
end
```

The numbers may not go exactly in order depending on the order in which the parallel workers finish, but they'll be close enough so you'll get the idea of where you are.

The technique of using a single file to store the iteration information was inspired
by this file exchange utility:

http://www.mathworks.com/matlabcentral/fileexchange/32101-progress-monitor--progress-bar--that-works-with-parfor
