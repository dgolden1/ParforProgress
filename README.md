Class to monitor progress of parfor loop

The parallel workers write to a common file for each iteration and determine the total number of completed iterations by counting the number of lines in the file.

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

See this code on the Matlab file exchange: http://www.mathworks.com/matlabcentral/fileexchange/48705-parforprogress-class

The technique of using a single file to store the iteration information was inspired by this file exchange utility:

http://www.mathworks.com/matlabcentral/fileexchange/32101-progress-monitor--progress-bar--that-works-with-parfor

