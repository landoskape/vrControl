classdef DaqRewardValve < hw.RewardController
  %HW.DAQREWARDVALVE Controls a valve via a DAQ to deliver reward
  %   Must (currently) be sole outputer on DAQ session
  %   TODO
  % Part of Rigbox
  
  % 2013-01 CB created    
  
  properties
    DaqSession; % should be a DAQ session containing just one output channel
    TriggerSession; 
    DaqId = 'Dev1'; % the DAQ's device ID, e.g. 'Dev1'
    DaqChannelId = 'ao1'; % the DAQ's ID for the counter channel. e.g. 'ao0'
    % for controlling the reward valve
    OpenValue = 6;
    ClosedValue = 0;
    MeasuredDeliveries; % deliveries with measured volumes for calibration.
    % This should be a struct array with fields 'durationSecs' & 
    % 'volumeMicroLitres' indicating the duration the valve was open, and the
    % measured volume (in ul) for that delivery. These points are interpolated 
    % to work out how long to open the valve for arbitrary volumes.
  end
  
  properties (Access = protected)
    CurrValue;
  end
  
  methods
    
      function createDaqChannel(obj)
          obj.DaqSession.addAnalogOutputChannel(obj.DaqId, obj.DaqChannelId, 'Voltage');
          obj.DaqSession.outputSingleScan(obj.ClosedValue);
          
          % Create digital listener
          % Dev1/PFI2 is where we manually added a cable
          obj.DaqSession.addTriggerConnection('External', 'Dev1/PFI2', 'StartTrigger');
          obj.DaqSession.ExternalTriggerTimeout = Inf;
          obj.DaqSession.TriggersPerRun = Inf;
          
          prepareDigitalTrigger(obj);
      end
      
      function prepareDigitalTrigger(obj)
          obj.TriggerSession = daq.createSession('ni');
          obj.TriggerSession.addDigitalChannel('Dev1', 'port1/line0', 'OutputOnly'); %use whatever channel you have available
          obj.TriggerSession.outputSingleScan(0);
      end
      
      function prepareRewardDelivery(obj, size, unitytype)
          if obj.DaqSession.IsRunning
              obj.DaqSession.stop();
          end
          if nargin<3
              unitytype = 'ul';
          end
          if strcmp(unitytype,'s')
              duration = size;
          elseif strcmp(unitytype,'ul')
              duration = openDurationFor(obj, size);
          else
              disp('assumed input is required size in ul, if not specify unity type')
              duration = openDurationFor(obj, size);
          end
          sampleRate = obj.DaqSession.Rate;
          nOpenSamples = round(duration*sampleRate);
          samples = [obj.OpenValue*ones(nOpenSamples, 1) ; ...
              obj.ClosedValue*ones(3,1)];
          obj.DaqSession.queueOutputData(samples);
          obj.DaqSession.startBackground();
      end
      function duration = openDurationFor(obj, microLitres)
          % Returns the duration the valve should be opened for to deliver
          % microLitres of reward. Is calibrated using interpolation of the
          % measured delivery data.
          volumes = [obj.MeasuredDeliveries.volumeMicroLitres];
          durations = [obj.MeasuredDeliveries.durationSecs];
          if microLitres > max(volumes) || microLitres < min(volumes)
              fprintf('Warning requested delivery of %.1f is outside calibration range\n',...
                  microLitres);
          end
          %JUL 07.07.2015
          %interpolation method changed to spline to allow interpolation
          %outside of the calibration range
          duration = interp1(volumes, durations, microLitres, 'spline');
          %       duration = interp1(volumes, durations, microLitres, 'PCHIP');
      end
      
      
      function activateDigitalDelivery(obj)
          obj.TriggerSession.outputSingleScan(1);
          obj.TriggerSession.outputSingleScan(0);
      end
      
      function deliverBackground(obj, ~, ~)
          % the two inputs (size and unittype, usually) are present for 
          % compatibility with other RewardController methods, but are not
          % relevant for this digital valve controller
          obj.activateDigitialDelivery()
      end
      function deliverMultiple(obj, ~, interval, n, ~)
          % Delivers n rewards in shots spaced in time by at least interval.
          % Useful for example, for obtaining calibration data.
          % size (second argument) and sizeIsOpenDuration (5th arg) are 
          % present for compatiblity with RewardController methods but are
          % not relevant for this digital valve controller
          if isempty(interval)
            interval = 0.1; % seconds - good interval given open/close delays
          end
          
          for i = 1:n
              obj.activateDigitalDelivery()
              pause(interval)
          end
          
          fprintf('%i rewards delivered.\n', n);
      end
  end
  
end

