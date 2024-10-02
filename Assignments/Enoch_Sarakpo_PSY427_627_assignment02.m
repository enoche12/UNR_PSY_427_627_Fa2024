% Skip sync tests for now (sync tests cause issues on Mac OS)
Screen('Preference', 'SkipSyncTests', 1);         

% Choosing the display with the highest display number.
screens=Screen('Screens');
screenNumber=max(screens);

% Open window with default settings:
screenColor = [128,128,128];
screenSize = [400,400];
screenUpperLeft = [200,200];
screenRect = [screenUpperLeft, screenUpperLeft + screenSize];
w=Screen('OpenWindow', screenNumber, screenColor, screenRect);

%%
% Block1 Translation 
totalTime = 20;  % Total nblocks
Durationofstim = 2; 
gapTime = 0.5;  % 0.5 second gap 
cycleTime = Durationofstim + gapTime;  % full cycle
numCycles = floor(totalTime / cycleTime);  % number of full motion + gap cycles within the block
numDots = 200;
ifi = 0.016;  % inter-frame interval (60 Hz refresh rate)
w = 10;  % window pointer
dotSize = 5;  %  dot size
vbl = 0;  % initial vertical blanking interval

for repeat = 1:2  % 2xnot same
    if repeat == 2
        dotSpeed = 4;  
    else
        dotSpeed = 2;  % initial
    end
    
    % Initialize dot positions for the block
    dotPositions = [rand(1, numDots) * screenSize(1); rand(1, numDots) * screenSize(2)];
    
    % Run the cycles
    for cycle = 1:numCycles
        % 2 seconds of motion
        cycleFrames = round(Durationofstim / ifi);
        for frame = 1:cycleFrames
            % Update dot positions and wrap them as before
            dotPositions(1, :) = dotPositions(1, :) + dotSpeed;
            offScreenDots = dotPositions(1, :) > screenSize(1);
            dotPositions(1, offScreenDots) = 0;
            % Draw the dots
            Screen('DrawDots', w, dotPositions, dotSize, [255 255 255], [], 2);
            vbl = Screen('Flip', w, vbl + (0.5 * ifi));
        end
        
        % 0.5 seconds of non motion dots
        cycleFrames = round(gapTime / ifi);  % Number of frames for the frozen period
        for frame = 1:cycleFrames
            % Draw the dots in their current (frozen) positions
            Screen('DrawDots', w, dotPositions, dotSize, [255 255 255], [], 2);
            vbl = Screen('Flip', w, vbl + (0.5 * ifi));
        end
    end
    % 3-second gap between repeats
    WaitSecs(3);
end

% %% Block 2 Spiral Dots
Durationofblock = 20;  % block time
Durationofstim = 2;  % stimulus duratio
gapTime = 0.5;  % 0.5-second gap (frozen dots)
cycleTime = Durationofstim + gapTime;  % Time for one cycle
% Calculate number of full motion + gap cycles within the block
numCycles = floor(totalTime / cycleTime);

for repeat = 1:2  % 2x above
    if repeat == 2
        rotationSpeed = 4;  
        expansionSpeed = 4;
    else
        rotationSpeed = 2;  
        expansionSpeed = 2;
    end

    % Initialize dot positions and polar coordinates for spiral movement
    dotPositions = [rand(1, numDots) * screenSize(1); rand(1, numDots) * screenSize(2)];
    angles = rand(1, numDots) * 2 * pi;
    radii = rand(1, numDots) * (min(screenSize) / 2);

    % Run the cycles
    for cycle = 1:numCycles
        % 2 seconds of spiral motion
        cycleFrames = round(Durationofstim / ifi);
        for frame = 1:cycleFrames
            % Update angle (for rotation) and radius (for spiral effect)
            angles = angles + rotationSpeed;
            radii = radii + expansionSpeed;
            % Convert polar coordinates (radii, angles) to Cartesian (x, y)
            dotPositions(1, :) = screenSize(1) / 2 + radii .* cos(angles);  % x-coordinates
            dotPositions(2, :) = screenSize(2) / 2 + radii .* sin(angles);  % y-coordinates
            % Handle off-screen dots and reset
            offScreenDots = (dotPositions(1, :) < 0 | dotPositions(1, :) > screenSize(1)) | ...
                            (dotPositions(2, :) < 0 | dotPositions(2, :) > screenSize(2));
            radii(offScreenDots) = rand(1, sum(offScreenDots)) * (min(screenSize) / 2);  % Reset radius
            angles(offScreenDots) = rand(1, sum(offScreenDots)) * 2 * pi;  % Reset angle
            % Draw the dots
            Screen('DrawDots', w, dotPositions, dotSize, [255 255 255], [], 2);
            vbl = Screen('Flip', w, vbl + (0.5 * ifi));
        end

        % 0.5 seconds of motionless dots
        cycleFrames = round(gapTime / ifi);  % Number of frames for the frozen period
        for frame = 1:cycleFrames
            % Draw the dots in their current (frozen) positions
            Screen('DrawDots', w, dotPositions, dotSize, [255 255 255], [], 2);
            vbl = Screen('Flip', w, vbl + (0.5 * ifi));
        end
    end
    % 3-second gap between repeats
    WaitSecs(3);
end
%%
%Block 3 (Expanding Dots)
totalTime = 20; % Total block time in seconds
Durationofstim = 2; % 2 seconds
gapTime = 0.5; % 0.5-seconds
cycleTime = Durationofstim + gapTime; % full cycle
numStars = 200;
initialDotSize = 0.5;
maxDotSize = 0.8;
numCycles = floor(totalTime / cycleTime);
ifi = 0.016; % inter-frame interval
w = 10; %  window pointer
vbl = 0; % vertical blanking interval

for repeat = 1:2 % 2x
    if repeat == 2
        speedFactor = 4; 
    else
        speedFactor = 2; % initial
    end

   % Initialize dotr positions and speeds
    dotPositions = [rand(1, numDots) * screenSize(1); rand(1, numDots) * screenSize(2)];
    dotSpeeds = rand(1, numDots) * 5 + speedFactor;
    dotSizes = ones(1, numDots) * initialDotSize;

    % Run the cycles
    for cycle = 1:numCycles
        % 2 seconds of expanding stars motion
        cycleFrames = round(Durationofstim / ifi);
        for frame = 1:cycleFrames
            % Update star positions and sizes
            deltaX = (dotPositions(1, :) - screenSize(1)/2) .* dotSpeeds * ifi;
            deltaY = (dotPositions(2, :) - screenSize(2)/2) .* dotSpeeds * ifi;
           dotPositions(1, :) = dotPositions(1, :) + deltaX;
            dotPositions(2, :) = dotPositions(2, :) + deltaY;
            dotSizes = dotSizes + 0.1 * dotSpeeds;

            % Handle off-screen 
            offScreenDots = (dotPositions(1, :) < 0 | dotPositions(1, :) > screenSize(1)) | ...
                             (dotPositions(2, :) < 0 | dotPositions(2, :) > screenSize(2)) | ...
                             (dotSizes > maxDotSize);
            dotPositions(:, offScreenDots) = [rand(1, sum(offScreenDots)) * screenSize(1); ...
                                                rand(1, sum(offScreenDots)) * screenSize(2)];
            dotSizes(offScreenDots) = initialDotSize; % Reset size
            dotSpeeds(offScreenDots) = rand(1, sum(offScreenDots)) * 5 + speedFactor; 

            % Draw the dots
            Screen('DrawDots', w, dotPositions, dotSizes, [255 255 255], [], 2);
            vbl = Screen('Flip', w, vbl + (0.5 * ifi));
        end

        % 0.5 seconds of motioless dots
        cycleFrames = round(gapTime / ifi); 
        for frame = 1:cycleFrames
            % Draw the stars in their current (frozen) positions
            Screen('DrawDots', w, dotPositions, dotSizes, [255 255 255], [], 2);
            vbl = Screen('Flip', w, vbl + (0.5 * ifi));
        end
    end  


end

%%
% close window:
sca;


