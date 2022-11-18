function msg = PsychImagingNonverbose(cmd, varargin)
msg = evalc('PsychImaging(cmd,varargin{:})');
% only works with no outputs... I can probably make it work with outputs
% but don't think it's worth it at this point...
