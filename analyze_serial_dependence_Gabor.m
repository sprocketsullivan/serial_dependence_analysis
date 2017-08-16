function [] = analyze_serial_dependence_Gabor()


save_path = '/Users/jasonfischer/Desktop/serial_dependence_save';

%% select data files
data_files = uipickfiles('FilterSpec',[save_path '/*.txt'],'Prompt','Select data file:','NumFiles',[],'Output','cell');


c = sqrt(2)/exp(-.5); % constant used for curve fitting
n_back = 1; % analyze for an effect of the nth trial back


%% load the data from all runs
all_data = [];
for file_num = 1:size(data_files,2)

    data = [];
    
    fid = fopen(data_files{file_num});
    tline = fgetl(fid); %skip first 2 lines that contain header information
    tline = fgetl(fid);
    
    line = 1;

    while 1
        tline = fgetl(fid);
        if ~ischar(tline),   break,   end
        data(line,:) = str2num(tline);
        line = line+1;
    end
    fclose(fid);
    
    
    % put responses on same scale as stims
    data(:,2) = mod(data(:,2)-1,180)+1;
    
    % in orientation space, an error > 90 in absolute value is actually a smaller error in the other direction.
    % assume the smaller error and correct accordingly.
    errors = data(:,1) - data(:,2);
    errors(errors < -90) = errors(errors < -90) + 180;
    errors(errors > 90) = errors(errors > 90) - 180;
    
    separations = data(:,1) - circshift(data(:,1),n_back);
    separations(separations < -90) = separations(separations < -90) + 180;
    separations(separations > 90) = separations(separations > 90) - 180;  

    all_data = [all_data;[data(n_back+1:end,1) separations(n_back+1:end) errors(n_back+1:end)]]; %don't use first n trials of each run
    
end


figure

scatter(all_data(:,2),all_data(:,3));hold on
% axis([-100 100 -30 30])

%display running average
bin_means = zeros(181,1);
for bin_pos = -90:90
    bin_data = all_data(((all_data(:,2) > bin_pos - 20) + (all_data(:,2) < bin_pos + 20)) == 2,3);
    bin_means(bin_pos + 91) = mean(bin_data);
end

plot(-90:90,bin_means,'k','LineWidth',3)


estimates = fit_s_curve_flag(all_data(:,2), all_data(:,3));
%solid line for curve fit
plot(min(all_data(:,2)):max(all_data(:,2)),estimates(1)*estimates(2)*c*(min(all_data(:,2)):max(all_data(:,2))).*exp(-((estimates(2)*(min(all_data(:,2)):max(all_data(:,2)))).^2)),'r','LineWidth',2);



% %shuffle the data and refit the curve to generate a permuted null distribution
%
% num_its = 1000;
% perm_results = zeros(num_its,2);
% 
% for iteration = 1:num_its
% 
%     permuted_data = [shake_rows(all_data(:,2)) all_data(:,3)];
%     
%     [estimates, flag] = fit_s_curve_flag(permuted_data(:,1), permuted_data(:,2));
% 
%     if flag
%         perm_results(iteration,:) = estimates;
%     else
%         perm_results(iteration,:) = [NaN NaN];
%     end
%     
% end
% 
% figure
% hist(perm_results(:,1))



%%%%%%%%%% functions %%%%%%%%%%

function [estimates, exitflag, sum_sqr_err] = fit_s_curve_flag(xdata, ydata)
%returns a flag indicating whether fminsearch converged

c = sqrt(2)/exp(-.5);
start_point = [rand*10 rand/50];
model = @s_curve;
options = optimset('Display','off'); %this will suppress nonconvergence warnings
[estimates,~,exitflag] = fminsearch(model, start_point, options);
sum_sqr_err = s_curve(estimates);

    function [sse] = s_curve(params)
        a = params(1);
        b = params(2);
        FittedCurve = a*b*c*xdata.*exp(-((b*xdata).^2));
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
end



function [shake_array] = shake_rows(array)
    shake_array = sortrows([array randperm(size(array,1))'],size(array,2)+1);
    shake_array(:,size(shake_array,2)) = [];
end


end %end main function
