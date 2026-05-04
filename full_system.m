clc; clear; close all;

%% ===============================
% UI FIGURE
%% ===============================
fig = uifigure('Name','UHI Smart Building Analyzer',...
    'Position',[100 100 1000 600]);

fig.Color = [0.95 0.97 1]; % light background

%% ===============================
% INPUT PANEL
%% ===============================
input_panel = uipanel(fig,'Title','Building Inputs',...
    'Position',[10 300 260 280]);

uilabel(input_panel,'Text','Roof Area (m^2):','Position',[10 220 120 22]);
A_roof_input = uieditfield(input_panel,'numeric','Position',[140 220 100 22],'Value',400);

uilabel(input_panel,'Text','Wall Area (m^2):','Position',[10 180 120 22]);
A_wall_input = uieditfield(input_panel,'numeric','Position',[140 180 100 22],'Value',960);

uilabel(input_panel,'Text','Window Area (m^2):','Position',[10 140 120 22]);
A_window_input = uieditfield(input_panel,'numeric','Position',[140 140 100 22],'Value',50);

uilabel(input_panel,'Text','SHGC:','Position',[10 100 120 22]);
SHGC_input = uieditfield(input_panel,'numeric','Position',[140 100 100 22],'Value',0.7);

uilabel(input_panel,'Text','Roof Absorptivity (α):','Position',[10 60 140 22]);
alpha_input = uieditfield(input_panel,'numeric','Position',[160 60 80 22],'Value',0.6);

uilabel(input_panel,'Text','UHI Temp (°C):','Position',[10 20 120 22]);
T_UHI_input = uieditfield(input_panel,'numeric','Position',[140 20 100 22],'Value',32);

%% ===============================
% MITIGATION PANEL
%% ===============================
mit_panel = uipanel(fig,'Title','Mitigation Strategies',...
    'Position',[10 150 260 130]);

coolroof_toggle = uicheckbox(mit_panel,'Text','Cool Roof','Position',[10 80 150 22]);
lowshgc_toggle = uicheckbox(mit_panel,'Text','Low SHGC Glass','Position',[10 50 150 22]);
shading_toggle = uicheckbox(mit_panel,'Text','Shading (Trees/Overhangs)','Position',[10 20 200 22]);

%% ===============================
% RESULT PANEL
%% ===============================
result_panel = uipanel(fig,'Title','Results Summary',...
    'Position',[10 10 260 130]);

output_text = uilabel(result_panel,'Text','Run analysis to see results',...
    'Position',[10 10 240 100]);

%% ===============================
% AXES
%% ===============================
ax1 = uiaxes(fig,'Position',[300 320 300 220]);
title(ax1,'Energy Comparison')

ax2 = uiaxes(fig,'Position',[650 320 300 220]);
title(ax2,'Cooling Load vs Time')

ax3 = uiaxes(fig,'Position',[500 20 300 220]);
title(ax3,'Heat Contribution')

%% ===============================
% BUTTON
%% ===============================
uibutton(fig,'push','Text','Run Analysis',...
    'Position',[50 120 150 30],...
    'ButtonPushedFcn', @(btn,event) calculate(...
        A_roof_input, A_wall_input, A_window_input, ...
        SHGC_input, alpha_input, T_UHI_input, ...
        coolroof_toggle, lowshgc_toggle, shading_toggle, ...
        output_text, ax1, ax2, ax3));

%% ===============================
% MAIN FUNCTION
%% ===============================
function calculate(A_roof_input, A_wall_input, A_window_input, ...
    SHGC_input, alpha_input, T_UHI_input, ...
    coolroof_toggle, lowshgc_toggle, shading_toggle, ...
    output_text, ax1, ax2, ax3)

    %% INPUTS
    A_roof = A_roof_input.Value;
    A_wall = A_wall_input.Value;
    A_window = A_window_input.Value;
    SHGC = SHGC_input.Value;
    alpha = alpha_input.Value;
    T_UHI = T_UHI_input.Value;

    %% CONSTANTS
    T_in = 25;
    T_base = 29;
    U_wall = 1.7;
    U_roof = 2.5;
    G_peak = 800;

    %% TIME MODEL (24 hours)
    t = 0:23;
    G = max(0, G_peak * sin(pi*(t-6)/12));

    %% BASELINE CASE
    Q_wall_base = U_wall*A_wall*(T_base-T_in);
    Q_roof_base = U_roof*A_roof*(T_base-T_in);
    Q_solar_base = alpha*G*A_roof;
    Q_window_base = SHGC*G*A_window;

    Q_base_t = Q_wall_base + Q_roof_base + Q_solar_base + Q_window_base;
    E_base = sum(Q_base_t)*365/1000;

    %% APPLY MITIGATION
    if coolroof_toggle.Value
        alpha = 0.3;
    end

    if lowshgc_toggle.Value
        SHGC = 0.4;
    end

    beta = 1;
    if shading_toggle.Value
        beta = 0.6;
    end

    G = beta * G;

    %% UHI CASE
    Q_wall = U_wall*A_wall*(T_UHI-T_in);
    Q_roof = U_roof*A_roof*(T_UHI-T_in);
    Q_solar = alpha*G*A_roof;
    Q_window = SHGC*G*A_window;

    Q_total_t = Q_wall + Q_roof + Q_solar + Q_window;
    E_modified = sum(Q_total_t)*365/1000;

    %% PEAK LOAD
    [peak, idx] = max(Q_total_t);

    %% % CHANGE
    change = ((E_modified - E_base)/E_base)*100;

    %% ===============================
    % OUTPUT TEXT
    %% ===============================
    if change < 0
        insight = "Energy Reduced (Mitigation Effective)";
    else
        insight = "Energy Increased (UHI Dominates)";
    end

    output_text.Text = sprintf(['Baseline: %.0f kWh\nModified: %.0f kWh\n\nChange: %.2f%%\nPeak Load: %.0f W\n\n%s'],...
        E_base, E_modified, change, peak, insight);

    %% ===============================
    % BAR GRAPH
    %% ===============================
    bar(ax1,[E_base E_modified])
    ax1.XTickLabel = {'Baseline','Modified'};
    ylabel(ax1,'Energy (kWh)')

    %% ===============================
    % TIME GRAPH
    %% ===============================
    cla(ax2)
    hold(ax2,'on')
    plot(ax2,t,Q_base_t,'--','LineWidth',1.5)
    plot(ax2,t,Q_total_t,'LineWidth',2)
    plot(ax2,t(idx),peak,'ro','MarkerSize',8,'LineWidth',2)
    legend(ax2,{'Baseline','Modified','Peak'})
    xlabel(ax2,'Time (hours)')
    ylabel(ax2,'Cooling Load (W)')
    title(ax2,sprintf('Cooling Load (%.2f%% change)',change))
    grid(ax2,'on')
    hold(ax2,'off')

    %% ===============================
    % PIE CHART
    %% ===============================
    Q_wall_avg = mean(Q_wall);
    Q_roof_avg = mean(Q_roof + Q_solar);
    Q_window_avg = mean(Q_window);

    pie(ax3,[Q_wall_avg Q_roof_avg Q_window_avg])
    legend(ax3,{'Walls','Roof + Solar','Windows'},'Location','southoutside')

end