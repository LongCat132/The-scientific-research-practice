global screens screenNumber win wsize flipIntv slack cx cy time_stamp include_feedback include_masks include_interference include_noise include_count instruction

include_feedback = false;
include_masks = false;
include_interference = false;
include_noise = true;
include_count = false;
instruction = true;
count = 0;
bonus = 1;
punishment = -1;
Total_trial = 50;

try
    ListenChar(2);
    KbName('UnifyKeyNames');
    space = KbName('space');
    key_target = KbName('=+');
    key_notarget = KbName('-_');
    key_next = KbName('return');

    f = 44100;
    [sound1,~] = MakeBeep(440,0.5,f);
    
    HideCursor;
    InitializeMatlabOpenGL;
    Screen('Preference','SkipSyncTests',1);
    Screen('Preference','TextEncodingLocale','UTF-8');

    screens=Screen('Screens');
    screenNumber=max(screens);

    [win,wsize]=Screen('OpenWindow',screenNumber);
    Screen('TextFont', win, 'Simsun');

    cx = wsize(3)/2; cy = wsize(4)/2;

    flipIntv = Screen('GetFlipInterval', win);
    slack = flipIntv/2;
    
    Screen('FillRect', win, 128);
    Screen('TextFont',win,'Arial');

    txt='Welcome to DEMO';
    bRect = Screen('TextBounds',win,txt);
    Screen('DrawText', win, txt, cx-bRect(3)/2, cy-bRect(4)/2,255);
    time_stamp = Screen('Flip',win);

    Screen('TextFont',win,'Simhei');
    Screen('TextSize',win,24);
    instruction_1='本实验中您将看到一系列成对出现的字母，在每一对字母出现前都有一个注视点作为提示，每一对字母中的';
    instruction_2='两个字母之间有数秒的间隔。您的任务是判断两个字母是否分别是A和X，如果不是的话按下键盘上的减号（-）键，';
    instruction_3='如果是的话按下键盘上的等于号（=）键。';
    instruction_4='请尽量快且准确地做出反应！';
    Screen('DrawText',win,double(instruction_1),150,cy-100,255);
    Screen('Drawtext',win,double(instruction_2),100,cy-50,255);
    Screen('DrawText',win,double(instruction_3),100,cy,255);
    Screen('DrawText',win,double(instruction_4),150,cy+50,255);
    instruction_5=' ';
    if(include_count)
        instruction_5=sprintf('在屏幕的左上角会显示您实时的得分，每正确反应加%d分，每错误反应扣%d分。',bonus,-punishment);
    end
    if(include_noise)
        instruction_5='在两个字母呈现的间隔中会出现噪音，您应当忽略这些噪音并做出反应。';
    end
    if(include_interference)
        instruction_5='在呈现每个字母对的第二个字母时，旁边会出现两个干扰字母，您应当忽略它们。';
    end
    if(include_masks)
        instruction_5='在两个字母呈现的间隔中会出现屏蔽，您应当忽略这一屏蔽并作出反应。';
    end
    if(include_feedback)
        instruction_5='在每次反应后会短暂显示您本次反应正确与否，正确为绿色，错误为红色';
    end
    Screen('DrawText',win,double(instruction_5),150,cy+100,255);
    time_stamp = Screen('Flip',win,time_stamp+1);
    Screen('TextFont',win,'Arial')

    Screen('FillRect',win,128);
    time_stamp = Screen('Flip',win,time_stamp+10);
    % sound(sound1',f); 

    pixs = deg2pix(5,13.3,wsize(3),50);

    AX_trial = Total_trial*0.7;
    others_trial = Total_trial*0.1;
    trial_pool = [linspace(1,1,AX_trial),linspace(2,2,others_trial),linspace(3,3,others_trial),linspace(4,4,others_trial)]; %1 for AX, 2 for AY, 3 for BX, 4 for BY

    trial_order = trial_pool(randperm(numel(trial_pool)));
    
    stimuli.trial_order = trial_order;
    stimuli.cue = [];
    stimuli.probe = [];

    alphabet = char(65:90);
    Y = alphabet;
    Y(Y=='X') = [];
    B = alphabet;
    B(B=='A') = [];

    for i = 1:Total_trial
        switch stimuli.trial_order(i)
            case 1
                stimuli.cue(i) = 'A';
                stimuli.probe(i) = 'X';
            case 2
                stimuli.cue(i) = 'A';
                stimuli.probe(i) = Y(randi(numel(Y)));
            case 3
                stimuli.cue(i) = B(randi(numel(B)));
                stimuli.probe(i) = 'X';
            case 4
                stimuli.cue(i) = B(randi(numel(B)));
                stimuli.probe(i) = Y(randi(numel(Y)));
        end
    end

    trial_interval = 1;
    trial_interval = time2frame(flipIntv,trial_interval);
    fix_onset = 0.5;
    fix_onset = time2frame(flipIntv,fix_onset);
    SOA_onset = 4.5;
    SOA_onset = time2frame(flipIntv,SOA_onset);
    stimulus_onset = 0.5;
    stimulus_onset = time2frame(flipIntv,stimulus_onset);

    response_pool = [];
    RT_pool = [];
    response_true = [];

    for i = 1:Total_trial
        sound(sound1'.*0.5,f);
        Screen('FillRect',win,128);
        if(include_count)
            Screen('TextSize',win,24);
            Screen('TextFont',win,'Simhei');
            count_txt = sprintf('得分：%d',count);
            Screen('DrawText',win,double(count_txt),10,10,255);
            Screen('TextSize',win,128);
            Screen('TextFont',win,'Arial');
        end
        %Screen('FillOval',win,255,[cx-5,cy-5,cx+5,cy+5]);
        Screen('DrawLine',win,255,cx-10,cy,cx+10,cy,3);
        Screen('DrawLine',win,255,cx,cy-10,cx,cy+10,3);
        time_stamp = Screen('Flip',win,time_stamp+(trial_interval-0.5)*flipIntv);
        

        Screen('FillRect',win,128);
        if(include_count)
            Screen('TextSize',win,24);
            Screen('TextFont',win,'Simhei');
            count_txt = sprintf('得分：%d',count);
            Screen('DrawText',win,double(count_txt),10,10,255);
            Screen('TextSize',win,128);
            Screen('TextFont',win,'Arial');
        end
        Screen('TextSize',win,128);
        cue_txt = char(stimuli.cue(i));
        bRect = Screen('TextBounds',win,cue_txt);
        Screen('DrawText',win,cue_txt,cx-bRect(3)/2,cy-bRect(4)/2,255);
        time_stamp = Screen('Flip',win,time_stamp+(fix_onset-0.5)*flipIntv);

        Screen('FillRect',win,128);
        if(include_count)
            Screen('TextSize',win,24);
            Screen('TextFont',win,'Simhei');
            count_txt = sprintf('得分：%d',count);
            Screen('DrawText',win,double(count_txt),10,10,255);
            Screen('TextSize',win,128);
            Screen('TextFont',win,'Arial');
        end
        if(include_masks)
            masks=im2uint8(rand(50));
            Image_Index = Screen('MakeTexture',win,masks);
            Screen('DrawTexture',win,Image_Index,[],[cx-pixs,cy-pixs,cx+pixs,cy+pixs]);
        end
        if(include_noise)
            duration=0.9;f=44100;
            noise=rand(2,duration*f);
            sound(noise.*0.1);
        end
        time_stamp = Screen('Flip',win,time_stamp+(stimulus_onset-0.5)*flipIntv);

        Screen('FillRect',win,128);
        if(include_count)
            Screen('TextSize',win,24);
            Screen('TextFont',win,'Simhei');
            count_txt = sprintf('得分：%d',count);
            Screen('DrawText',win,double(count_txt),10,10,255);
            Screen('TextSize',win,128);
            Screen('TextFont',win,'Arial');
        end
        probe_txt = char(stimuli.probe(i));
        bRect = Screen('TextBounds',win,probe_txt);
        Screen('DrawText',win,probe_txt,cx-bRect(3)/2,cy-bRect(4)/2,255);
        if(include_interference)
            interference_txt = alphabet(randi(numel(alphabet)));
            Screen('DrawText',win,interference_txt,cx-bRect(3)/2-100,cy-bRect(4)/2,255);
            interference_txt = alphabet(randi(numel(alphabet)));
            Screen('DrawText',win,interference_txt,cx-bRect(3)/2+100,cy-bRect(4)/2,255);
        end
        time_stamp = Screen('Flip',win,time_stamp+(SOA_onset-0.5)*flipIntv);

        start_time = GetSecs;
        response_pool(i) = nan;
        RT_pool(i) = nan;
        while(GetSecs-start_time<(stimulus_onset+trial_interval)*flipIntv)
            [K_down,~,K_code] = KbCheck;
            if(K_down)
                RT_pool(i) = GetSecs-start_time;
                response_pool(i) = find(K_code);
                if(K_code(space))
                    sca;
                    stats.subinfo={'zl','Male','21yrs'};
                    stats.trial_num=Total_trial;
                    stats.trial_order=stimuli.trial_order;
                    stats.cue=stimuli.cue;
                    stats.probe=stimuli.probe;
                    stats.response={RT_pool,response_pool,response_true};
                    stats.condition=[include_feedback,include_interference,include_count,include_noise,include_masks];
                    stats.docs='1 for AX, 2 for AY, 3 for BX, 4 for BY';
                    save result.mat stats
                    ListenChar(0);
                    return
                elseif(K_code(key_target))
                    if(trial_order(i)==1)
                        response_true(i) = 1;
                    else
                        response_true(i) = 0;
                    end
                elseif(K_code(key_notarget))
                    if(trial_order(i)==1)
                        response_true(i) = 0;
                    else
                        response_true(i) = 1;
                    end
                else
                    response_true(i) = 0;
                end
                break
            end
        end
        Screen('FillRect',win,128);
        if(response_true(i))
            count = count+bonus;
        else
            count = count+punishment;
        end
        if(include_count)
            Screen('TextSize',win,24);
            Screen('TextFont',win,'Simhei');
            if(response_true(i))
                color = [0,255,0];
            else
                color = [255,0,0];
            end
            count_txt = sprintf('得分：%d',count);
            Screen('DrawText',win,double(count_txt),10,10,color);
            Screen('TextSize',win,128);
            Screen('TextFont',win,'Arial');
        end
        if(include_feedback)
            if(response_true(i))
                feedback = 'Correct';
                color = [0,255,0];
            else
                feedback = 'Wrong';
                color = [255,0,0];
            end
            bRect = Screen('TextBounds',win,feedback);
            Screen('DrawText',win,feedback,cx-bRect(3)/2,cy-bRect(4)/2,color);
        end
        time_stamp = Screen('Flip',win,time_stamp+(stimulus_onset-0.5)*flipIntv);
    end
    time_stamp = Screen('Flip',win,time_stamp+3);

    stats.subinfo={'zl','Male','21yrs'};
    stats.trial_num=Total_trial;
    stats.trial_order=stimuli.trial_order;
    stats.cue=stimuli.cue;
    stats.probe=stimuli.probe;
    stats.response={RT_pool,response_pool,response_true};
    stats.docs='1 for AX, 2 for AY, 3 for BX, 4 for BY';
    save result.mat stats
    
    Screen('CloseAll');
    ListenChar(0);
catch
    ListenChar(0);
    sca;
end

function nframe = time2frame(flipIntv,duration)
nframe=round(duration/flipIntv);
end

function pixs = deg2pix(degree,inch,pwidth,vdist)
screenWidth = inch*2.54/sqrt(1+9/16);
pix = screenWidth/pwidth;
pixs = round(2*tan((degree/2)*pi/180)*vdist/pix);
end
