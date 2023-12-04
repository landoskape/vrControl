classdef DaqRewardValve < hw.RewardController
  %HW.DAQREWARDVALVE Controls a valve via a DAQ to deliver reward
  %   Must (currently) be sole outputer on DAQ session
  %   TODO
  %
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
          % obj.CurrValue = obj.ClosedValue; % seems unnecessary
          
          % Create digital listener
          % Dev1/PFI2 is where we manually added a cable
          obj.DaqSession.addTriggerConnection('External', 'Dev1/PFI2', 'StartTrigger');
          obj.DaqSession.ExternalTriggerTimeout = Inf;
          obj.DaqSession.TriggersPerRun = Inf;
          
          prepareDigitalTrigger(obj);
      end
      
      function prepareDigitalTrigger(obj)
          obj.TriggerSession = daq.createSession('ni');
          % 'port1/line0' == PFI4 on this board
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
          %if obj.DaqSession.IsRunning
          %    obj.DaqSession.wait();
          %end
          obj.DaqSession.queueOutputData(samples);
          %obj.DaqSession.prepare() % probably unnecessary
          obj.DaqSession.startBackground();
      end
      
      function deliverReward(obj, method)
          if strcmp(method,'digital')
              obj.TriggerSession.outputSingleScan(1);
              obj.TriggerSession.outputSingleScan(0);
          else

          function deliverBackground(obj, size, unitytype)
              % size is the volume to deliver in microlitres (ul). This is turned
              % into an open duration for the valve using interpolation of the
              % calibration measurements.
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
              daqSession = obj.DaqSession;
              sampleRate = daqSession.Rate;
              nOpenSamples = round(duration*sampleRate);
              samples = [obj.OpenValue*ones(nOpenSamples, 1) ; ...
                obj.ClosedValue*ones(3,1)];
              if daqSession.IsRunning
                daqSession.wait();
              end
              % fprintf('Delivering %gul by opening valve for %gms\n', size, 1000*duration);
              daqSession.queueOutputData(samples);
              daqSession.startBackground();
              time = obj.Clock.now;
              obj.CurrValue = obj.ClosedValue;
              logSample(obj, size, time);
          end

      function activateDigitalDelivery(obj)
          
          obj.TriggerSession.outputSingleScan(1);
          obj.TriggerSession.outputSingleScan(0);
      end
      
      
      % -- ATL230106 I think that everything below here is unnecessary --
      function open(obj)
          daqSession = obj.DaqSession;
          if daqSession.IsRunning
              daqSession.wait();
          end
          daqSession.outputSingleScan(obj.OpenValue);
          obj.CurrValue = obj.OpenValue;
      end
      function close(obj)
          daqSession = obj.DaqSession;
          if daqSession.IsRunning
              daqSession.wait();
          end
          daqSession.outputSingleScan(obj.ClosedValue);
          obj.CurrValue = obj.ClosedValue;
      end
      function closed = toggle(obj)
          if obj.CurrValue == obj.ClosedValue
              open(obj);
              closed = false;
          else
              close(obj);
              closed = true;
          end
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
      function ul = microLitresFromDuration(obj, duration)
          % Returns the amount of reward the valve would delivery by being open
          % for the duration specified. Is calibrated using interpolation of the
          % measured delivery data.
          volumes = [obj.MeasuredDeliveries.volumeMicroLitres];
          durations = [obj.MeasuredDeliveries.durationSecs];
          ul = interp1(durations, volumes, duration, 'cubic');
      end
      
      function prepareDelivery(obj, size, unitytype)
          % size is the volume to deliver in microlitres (ul). This is turned
          % into an open duration for the valve using interpolation of the
          % calibration measurements.
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
          if obj.DaqSession.IsRunning
              obj.DaqSession.wait();
          end
          %       fprintf('Delivering %gul by opening valve for %gms\n', size, 1000*duration);
          obj.DaqSession.queueOutputData(samples);
          obj.DaqSession.prepare();
      end
      function go(obj)
          obj.DaqSession.startBackground();
      end
      function deliverBackground(obj, size, unitytype)
          % size is the volume to deliver in microlitres (ul). This is turned
          % into an open duration for the valve using interpolation of the
          % calibration measurements.
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
          daqSession = obj.DaqSession;
          sampleRate = daqSession.Rate;
          nOpenSamples = round(duration*sampleRate);
          samples = [obj.OpenValue*ones(nOpenSamples, 1) ; ...
              obj.ClosedValue*ones(3,1)];
          if daqSession.IsRunning
              daqSession.wait();
          end
          %       fprintf('Delivering %gul by opening valve for %gms\n', size, 1000*duration);
          daqSession.queueOutputData(samples);
          daqSession.startBackground();
          time = obj.Clock.now;
          obj.CurrValue = obj.ClosedValue;
          logSample(obj, size, time);
      end
      function performDelivery(obj)
          obj.DaqSession.startBackground();
          time = obj.Clock.now;
          obj.CurrValue = obj.ClosedValue;
          logSample(obj, time);
      end
      function deliverMultiple(obj, size, interval, n, sizeIsOpenDuration)
          % Delivers n rewards in shots spaced in time by at least interval.
          % Useful for example, for obtaining calibration data.
          % If sizeIsOpenDuration is true, then specified size is the open
          % duration of the valve, if false (default), then specified size is the
          % usual micro litres size converted to open duration using the measurement
          % data for calibration.
          if nargin < 5 || isempty(sizeIsOpenDuration)
              sizeIsOpenDuration = false; % defaults to size is in microlitres
          end
          if isempty(interval)
              interval = 0.1; % seconds - good interval given open/close delays
          end
          daqSession = obj.DaqSession;
          if daqSession.IsRunning
              daqSession.wait();
          end
          if sizeIsOpenDuration
              duration = size;
              size = microLitresFromDuration(obj, size);
          else
              duration = openDurationFor(obj, size);
          end
          sampleRate = daqSession.Rate;
          nsamplesOpen = round(sampleRate*duration);
          nsamplesClosed = round(sampleRate*interval);
          period = 1/sampleRate * (nsamplesOpen + nsamplesClosed);
          signal = [obj.OpenValue*ones(nsamplesOpen, 1) ; ...
              obj.ClosedValue*ones(nsamplesClosed, 1)];
          blockReps = 20;
          blockSignal = repmat(signal, [blockReps 1]);
          nBlocks = floor(n/blockReps);
          
          for i = 1:nBlocks
              % use the reward timer controller to open and close the reward valve
              daqSession.queueOutputData(blockSignal);
              time = obj.Clock.now;
              daqSession.startForeground();
              fprintf('rewards %i-%i delivered.\n', blockReps*(i - 1) + 1, blockReps*i);
              logSamples(obj, repmat(size, [1 blockReps]), ...
                  time + cumsum(period*ones(1, blockReps)) - period);
          end
          remaining = n - blockReps*nBlocks;
          for i = 1:remaining
              % use the reward timer controller to open and close the reward valve
              daqSession.queueOutputData(signal);
              time = obj.Clock.now;
              daqSession.startForeground();
              logSample(obj, size, time);
          end
          fprintf('rewards %i-%i delivered.\n', blockReps*nBlocks + 1, blockReps*nBlocks + remaining);
      end
  end
  
end

