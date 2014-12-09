classdef ParforProgress < handle
  % Class to monitor progress of parfor loop
  %
  % Create an empty file in the temporary directory for each iteration and count the
  % files to determine which iteration we're on
  %
  % USAGE
  % pp = ParforProgress;
  % parfor kk = 1:100
  %   DO_SOMETHING;
  %   fprintf('Finished iteration %d of %d\n', step(pp, kk), kk);
  % end
  %
  % The numbers may not go exactly in order depending on the order in which the parallel
  % workers finish, but they'll be close enough so you'll get the idea of where you are.
  
  % By Daniel Golden (dgolden1@gmail.com) May 2014
  % 
  % The technique of using a single file to store the iteration information was inspired
  % by
  % http://www.mathworks.com/matlabcentral/fileexchange/32101-progress-monitor--progress-bar--that-works-with-parfor

  properties
    TempFilename
    b_CreatedInParfor % True if this object was created within a parfor loop
  end
  
  methods
    function obj = ParforProgress
      temp_dir = tempdir;
      
      TEMP_FILE_MAX = 100;
      d = dir(fullfile(temp_dir, 'parfor_progress_*'));
      if length(d) == TEMP_FILE_MAX
        error('Exceeded allowable number of temporary random files (%d) in %s', TEMP_FILE_MAX, temp_dir);
      end
      
      b_found_open_filename = false;
      for kk = 1:TEMP_FILE_MAX
        obj.TempFilename = fullfile(temp_dir, sprintf('parfor_progress_%04d.txt', kk));
        if exist(obj.TempFilename, 'file')
          continue;
        else
          b_found_open_filename = true;
          break;
        end
        
        error('Too many parfor_progress files in %s', temp_dir);
      end
      
      if ~b_found_open_filename
        error('Unable to create temporary file in %s', temp_dir);
      end
      
      if ParforProgress.InParfor
        obj.b_CreatedInParfor = true;
      else
        obj.b_CreatedInParfor = false;
      end
    end
    
    function [iteration_number, cmd] = step(obj, loop_counter, varargin)
      % Step in the loop
      % [iteration_number, cmd] = step(obj, loop_counter, varargin)
      %
      % kk is the loop counter
      % iteration_number is the corrected current iteration
      %
      % PARAMETERS
      % b_calculate_iteration: return iteration number; if false, return 0 and let the
      % user run the command manually
      
      p = inputParser;
      p.addParameter('b_calculate_iteration', true);
      p.parse(varargin{:});

      % This is totally not thread safe... but it usually works fine
      fid = fopen(obj.TempFilename, 'a');
      assert(fid >= 0, 'Error opening file %s', obj.TempFilename);
      fprintf(fid, '%d\n', loop_counter);
      fclose(fid);
      
      if p.Results.b_calculate_iteration
        iteration_idx = GetLoopCounterList(obj);
        iteration_number = length(iteration_idx);
      else
        iteration_number = 0;
      end
      cmd = sprintf('wc -l %s', obj.TempFilename);
    end
    
    function iteration_idx = GetLoopCounterList(obj)
      % Get list of loop counters in the order that they ran
        fid = fopen(obj.TempFilename, 'r');
        iteration_idx = fscanf(fid, '%d');
        fclose(fid);
    end
    
    function delete(obj)
      % Destructor
      
      if ParforProgress.InParfor && ~obj.b_CreatedInParfor
        % Don't remove the file if we're in a parfor loop and this object wasn't
        % created in that loop. The parfor workers each individually try to delete the
        % ParforProgress object but we won't let them; let the calling function delete
        % them
        return;
      end
      delete(obj.TempFilename);
    end
  end
  
  methods (Static)
    function [times, iteration_idx] = Test
      % Unit test
      fun = @() pause(rand*0.001);
      
      pp = ParforProgress;
      num_iterations = 1000;
      times = zeros(num_iterations, 1);
      parfor kk = 1:num_iterations
        t_start = now;
        fun();
        iteration_number = step(pp, kk);
        times(kk) = now - t_start;
        fprintf('Completed iteration %d of %d in %s\n', iteration_number, num_iterations, time_elapsed(0, times(kk)));
      end
      iteration_idx = GetLoopCounterList(pp);
    end

    function [b_parfor, worker_id] = InParfor
      % Determine whether we're currently in a parfor loop
      % [b_parfor, worker_id] = ParforProgress.InParfor
      % 
      % b_parfor is true if we're in a parfor loop, false otherwise
      % If we're not in a parfor loop, worker_id = nan

      task = getCurrentTask;
      if isempty(task)
        b_parfor = false;
        worker_id = nan;
      else
        b_parfor = true;
        worker_id = task.ID;
      end
    end
  end
end
