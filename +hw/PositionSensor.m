classdef PositionSensor < hw.EventLogging
  %POSITIONSENSOR Abstract class for tracking positions from a sensor
  %   Takes care of logging positions and times every time readPosition is
  % called. Has a zeroing function.
  
  properties (Dependent = true)
    Positions
    PositionTimes
  end
  
  properties (Access = protected)
    ZeroOffset = 0;
  end

  methods
    [x, time] = readAbsolutePosition(obj)
  end
  
  methods
    function clearPositionData(obj)
      clearEventData(obj);
    end    
    function value = get.Positions(obj)
      value = obj.ValuesBuffer(1:obj.EventCount);
    end
    function value = get.PositionTimes(obj)
      value = obj.TimesBuffer(1:obj.EventCount);
    end    
  end
  
end