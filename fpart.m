function dec = fpart(float)
% Return the floating part of the number
% 
% For a negative number, the result is negative

% By Daniel Golden (dgolden1 at gmail dot com) June, 2008
% $Id$

idx_pos = float >= 0;
dec(idx_pos) = float(idx_pos) - floor(float(idx_pos));
dec(~idx_pos) = float(~idx_pos) - ceil(float(~idx_pos));

dec = reshape(dec, size(float));
