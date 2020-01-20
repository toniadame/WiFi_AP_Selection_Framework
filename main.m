%-------------------------------------------------------------------------
% Channel load aware AP/Extender selection mechanism
%-------------------------------------------------------------------------
% main.m --> Main program to test multiple network configurations and
%             plot results
%-------------------------------------------------------------------------
% INPUT PARAMETERS
%-------------------------------------------------------------------------
%Keep the same random generated number
rng(2000)

%Main options
num_it = 1000;                      %Number of simulations (random STA positions)
random_pos = 1;                     %Random position of STAs (0:OFF/1:ON)
deploy = 1;                         %Type of deployment (0:circle/1:rectangle)
random_ch = 0;                      %Random selection of the channel
random_traffic = 0;                 %Random traffic selector

%Traffic
L = 12000;                          %Packet length [bits]
%lambda_gen = 1:1:300;              %Generation rate per STA [packets/s]
lambda_gen = 1:1:500;               %Generation rate per STA [packets/s]
%lambda_gen = 1:50:501;             %Generation rate per STA [packets/s]
%lambda_gen = 250;                  %Generation rate per STA [packets/s]
eps_gen = 0;                        %Standard deviation [packets/s]

%IEEE 802.11k/v capabilities (%)
kv_share_a = 100;                   %Share of STAs with 11k/v capabilities (%) in Option A
kv_share_b = 100;                   %Share of STAs with 11k/v capabilities (%) in Option B
kv_share_c = 100;                   %Share of STAs with 11k/v capabilities (%) in Option C
kv_share_d = 100;                   %Share of STAs with 11k/v capabilities (%) in Option D

%AP/Extender selection mechanism
score_mode_a = 4;                   %Score mode employed for Option A (WITH Extenders - To choose)
score_mode_b = 0;                   %Score mode employed for Option B (WITH Extenders - To choose)
score_mode_c = 0;                   %Score mode employed for Option C (WITH Extenders - To choose)
score_mode_d = 0;                   %Score mode employed for Option D (WITH Extenders - To choose)
score_mode_e = 0;                   %Score mode employed for Option E (WITHOUT Extenders)
%0: 802.11 RSSI-based
%1: Hops & children
%2: Optimized (weights)
%3: Threshold-based (thresholds)
%4: Load aware (paper)
%5: End-to-end latency based (paper)

%OPTION A: WITH Extenders (To choose)
if (score_mode_a == 0)
    w_a_a = 0;                      %Not used
    w_b_a = 0;                      %Not used
    w_c_a = 0;                      %Not used
    kv_share_a = 0;
elseif (score_mode_a == 1)
    w_a_a = 0;                      %Not used
    w_b_a = 2;                      %Penalization per hop
    w_c_a = 4;                      %Penalization per child
elseif (score_mode_a == 2)
    w_a_a = 3;                      %Penalization per hop
    w_b_a = 750;                    %Penalization per load in the access link
    w_c_a = 750;                    %Penalization per load in the backbone link
elseif (score_mode_a == 3)
    w_a_a = 3;                      %Hop penalization (dB)
    w_b_a = 75;                     %Maximum load in the access link (%)
    w_c_a = 50;                     %Maximum load in the backbone link (%)
elseif (score_mode_a == 4)
    w_a_a = 0;                      %Not used
    %w_b_a = 0:0.25:1;              %Penalization per load in the access link
    w_b_a = 0.5;
    w_c_a = 0.5;                      %Penalization per load in the backbone link
elseif (score_mode_a == 5)
    w_a_a = -75;                    %Not used
    w_b_a = 0;                      %Not used
    w_c_a = 0;                      %Not used
else
    disp('Score mode of OPTION A was not properly chosen');
    kv_share_a = 0;
end

%OPTION B: WITH Extenders (To choose)
if (score_mode_b == 0)
    w_a_b = 0;                      %Not used
    w_b_b = 0;                      %Not used
    w_c_b = 0;                      %Not used
    kv_share_b = 0;
elseif (score_mode_b == 1)
    w_a_b = 0;                      %Not used
    w_b_b = 2;                      %Penalization per hop
    w_c_b = 4;                      %Penalization per child
elseif (score_mode_b == 2)
    w_a_b = 3;                      %Penalization per hop
    w_b_b = 750;                    %Penalization per load in the access link
    w_c_b = 750;                    %Penalization per load in the backbone link
elseif (score_mode_b == 3)
    w_a_b = 3;                      %Hop penalization (dB)
    w_b_b = 75;                     %Maximum load in the access link (%)
    w_c_b = 50;                     %Maximum load in the backbone link (%)
elseif (score_mode_b == 4)
    w_a_b = 0;                      %Not used
    %w_b_b = 0:0.25:1;               %Penalization per load in the access link
    w_b_b = 0.5;
    w_c_b = 0.5;                      %Penalization per load in the backbone link
elseif (score_mode_b == 5)
    w_a_b = -75;                    %Not used
    w_b_b = 0;                      %Not used
    w_c_b = 0;                      %Not used
else
    disp('Score mode of OPTION B was not properly chosen');
    kv_share_b = 0;
end

%OPTION C: WITH Extenders (To choose)
if (score_mode_c == 0)
    w_a_c = 0;                      %Not used
    w_b_c = 0;                      %Not used
    w_c_c = 0;                      %Not used
    kv_share_c = 0;
elseif (score_mode_c == 1)
    w_a_c = 0;                      %Not used
    w_b_c = 2;                      %Penalization per hop
    w_c_c = 4;                      %Penalization per child
elseif (score_mode_c == 2)
    w_a_c = 3;                      %Penalization per hop
    w_b_c = 750;                    %Penalization per load in the access link
    w_c_c = 750;                    %Penalization per load in the backbone link
elseif (score_mode_c == 3)
    w_a_c = 3;                      %Hop penalization (dB)
    w_b_c = 75;                     %Maximum load in the access link (%)
    w_c_c = 50;                     %Maximum load in the backbone link (%)
elseif (score_mode_c == 4)
    w_a_c = 0;                      %Not used
    %w_b_c = 0:0.25:1;               %Penalization per load in the access link
    w_b_c = 0.5;
    w_c_c = 0.5;                      %Penalization per load in the backbone link
elseif (score_mode_c == 5)
    w_a_c = -75;                    %Not used
    w_b_c = 0;                      %Not used
    w_c_c = 0;                      %Not used
else
    disp('Score mode of OPTION C was not properly chosen');
    kv_share_c = 0; 
end

%OPTION D: WITH Extenders (To choose)
if (score_mode_d == 0)
    w_a_d = 0;                      %Not used
    w_b_d = 0;                      %Not used
    w_c_d = 0;                      %Not used
    kv_share_d = 0;
elseif (score_mode_d == 1)
    w_a_d = 0;                      %Not used
    w_b_d = 2;                      %Penalization per hop
    w_c_d = 4;                      %Penalization per child
elseif (score_mode_d == 2)
    w_a_d = 3;                      %Penalization per hop
    w_b_d = 750;                    %Penalization per load in the access link
    w_c_d = 750;                    %Penalization per load in the backbone link
elseif (score_mode_d == 3)
    w_a_d = 3;                      %Hop penalization (dB)
    w_b_d = 75;                     %Maximum load in the access link (%)
    w_c_d = 50;                     %Maximum load in the backbone link (%)
elseif (score_mode_d == 4)
    w_a_d = 0;                      %Not used
    %w_b_d = 0:0.25:1;              %Penalization per load in the access link
    w_b_d = 0.5;
    w_c_d = 0.5;                      %Penalization per load in the backbone link
elseif (score_mode_d == 5)
    w_a_d = -75;                    %Not used
    w_b_d = 0;                      %Not used
    w_c_d = 0;                      %Not used
else
    disp('Score mode of OPTION D was not properly chosen');
    kv_share_d = 0;
end

%Extender connection algorithm
ext_conn_alg = 0;                   %Extender connection algorithm 
%ext_conn_alg = 0: Based on RSSI (RSSI method)
%ext_conn_alg = 1: Based on total delay (UPF method)
margin_R = -70;                     %Margin for direct connection to the AP (dBm)

%Operating Frequency % Channel
WIFI_std = 0;                       %IEEE 802.11 standards employed
%WIFI_std = 0: IEEE 802.11n (2.4 GHz) + IEEE 802.11ac (5 GHz)
%WIFI_std = 1: IEEE 802.11ax (2.4 GHz) + IEEE 802.11ax (5 GHz)
f_backbone = 5E9;                   %Frequency band of backbone links [Hz]
f_access = 2.4E9;                   %Frequency band of access links [Hz]
PL_backbone = 1;                    %Path loss model selector of backbone links
PL_access = 1;                      %Path loss model selector of access links
%PL = 0 (default): Boris model (¿?)
%PL = 1: ITU-R model
%PL = 2: TMB model (Only for 5 GHz)
%PL = 3: IEEE 802.11ax Residential
%PL = 4: IEEE 802.11ax Enterprise

if  (random_ch == 0)
channel_R_a = [1 6 11];
channel_R_b = [1 6 11];
channel_R_c = [1 6 11];
channel_R_d = [1 6 11];
channel_R_e = [1];    
end

channel_load_ext = [0.6 0 0 0 0 0.6 0 0 0 0 0.6];

%Radio module
Pt = 20;                            %Transmission power [dBm]
Sens = -90;                         %Receiver's sensitivity [dBm]

%STA parameters and position
pos_AP = [0 0];
pos_R_a = [25 0; 50 0];
pos_R_b = [25 0; 50 0];
pos_R_c = [25 0; 50 0];
pos_R_d = [25 0; 50 0];
pos_R_e = [25 0; 50 0];
max_R_per_R = 30;                   %Maximum number of Extenders per Extender
max_STA_per_R = 30;                 %Maximum number of STAs per Extender

if (random_pos == 1)
    sta = 10;                       %Number of stations
    %Deployment: circle
    margin_under = 0;               %Position margin to deploy STAs far from coverage center [%]
    margin_over = 0;                %Position margin to deploy STAs far from coverage edge [%]
    R = MaxDistance(Pt-Sens,f_access,PL_access);
    %Deployment: rectangle
    side_h = 100;
    side_v = 20;
else
    pos_STA = [75 10; -25 -10; 65 5; 30 5; 30 -5; 55 -5; 60 -5; 65 -5; 70 -5; -25 10];
    sta = size(pos_STA,1);          %Number of stations
    num_it = 1;
end

%Sizes
exts_a = size(pos_R_a,1);           %Number of extenders
dev_a = exts_a + 1;                 %Total number of APs + extenders
exts_b = size(pos_R_b,1);           %Number of extenders
dev_b = exts_b + 1;                 %Total number of APs + extenders
exts_c = size(pos_R_c,1);           %Number of extenders
dev_c = exts_c + 1;                 %Total number of APs + extenders
exts_d = size(pos_R_d,1);           %Number of extenders
dev_d = exts_d + 1;                 %Total number of APs + extenders
exts_e = size(pos_R_e,1);           %Number of extenders
dev_e = exts_e + 1;                 %Total number of APs + extenders

% Time Parameters
TPHY = 40E-6;                       %PHY time
SIFS = 16E-6;                       %SIFS time
DIFS = 34E-6;                       %DIFS time
Tslot = 9E-6;                       %Slot time

%Computation options
map_R = 0;                          %Visualization of Extender map
%0: Do not show Extender map
%1: Show Extender map
map_STA = 0;                        %Visualization of STA map
%0: Do not show STA map
%1: Show final STA map (it affects computation time!!!)
%2: Show intermediate and final STA maps (it affects computation time!!!)

%SVM-based feed data
% dist = zeros(sta,dev,num_it);      %Distance matrix amongs STAs and AP/Extenders (m)

%-------------------------------------------------------------------------
% AUXILIAR VARIABLES
%-------------------------------------------------------------------------
% (Note that the first row of M corresponds to the AP, filled with 0s)
% M = [posX    posY    #hops   #Children_R  Parent_Index    Delay   Rate   Channel     #Children_S   lambda_R   DBPS    Airtime access  Airtime backbone]
%      1       2       3       4            5               6       7      8           9             10         11      12              13
M_a = zeros(dev_a,13);              % WITH Extenders (To choose)
M_b = zeros(dev_b,13);              % WITH Extenders (To choose)
M_c = zeros(dev_c,13);              % WITH Extenders (To choose)
M_d = zeros(dev_d,13);              % WITH Extenders (To choose)
M_e = zeros(1,13);                  % WITHOUT Extenders

M_a(1,1) = pos_AP(1);
M_a(1,2) = pos_AP(2);
M_b(1,:) = M_a(1,:);
M_c(1,:) = M_a(1,:);
M_d(1,:) = M_a(1,:);
M_e(1,:) = M_a(1,:);

M_a(2:end,1) = pos_R_a(:,1);
M_a(2:end,2) = pos_R_a(:,2);
M_b(2:end,1) = pos_R_b(:,1);
M_b(2:end,2) = pos_R_b(:,2);                      
M_c(2:end,1) = pos_R_c(:,1);
M_c(2:end,2) = pos_R_c(:,2);
M_d(2:end,1) = pos_R_d(:,1);
M_d(2:end,2) = pos_R_d(:,2);

%-------------------------------------------------------------------------
% PERFORMANCE METRICS VARIABLES
%-------------------------------------------------------------------------
%Definition of variables
%OPTION A: WITH Extenders (To choose)
S_T_a = zeros(length(w_b_a),length(w_c_a),num_it,length(lambda_gen));
E_T_a = zeros(length(w_b_a),length(w_c_a),num_it,length(lambda_gen));
E_T_ok_a = zeros(length(w_b_a),length(w_c_a),num_it,length(lambda_gen));
D_avg_a = zeros(length(w_b_a),length(w_c_a),num_it,length(lambda_gen));
D_max_a = zeros(length(w_b_a),length(w_c_a),num_it,length(lambda_gen));
SS_avg_a = zeros(length(w_b_a),length(w_c_a),num_it,length(lambda_gen));
SS_min_a = zeros(length(w_b_a),length(w_c_a),num_it,length(lambda_gen));
assoc_STA_a = zeros(length(w_b_a),length(w_c_a),num_it,length(lambda_gen));
assoc_STA_AP_a = zeros(length(w_b_a),length(w_c_a),num_it,length(lambda_gen));
assoc_STA_E_a = zeros(length(w_b_a),length(w_c_a),num_it,length(lambda_gen));

S_T_a_avg = zeros(length(w_b_a),length(w_c_a),length(lambda_gen));
E_T_a_avg = zeros(length(w_b_a),length(w_c_a),length(lambda_gen));
share_ok_a = zeros(length(w_b_a),length(w_c_a),length(lambda_gen));
D_avg_a_avg = zeros(length(w_b_a),length(w_c_a),length(lambda_gen));
D_max_a_avg = zeros(length(w_b_a),length(w_c_a),length(lambda_gen));
SS_avg_a_avg = zeros(length(w_b_a),length(w_c_a),length(lambda_gen));
SS_min_a_avg = zeros(length(w_b_a),length(w_c_a),length(lambda_gen));
assoc_STA_a_avg = zeros(length(w_b_a),length(w_c_a),length(lambda_gen));
assoc_STA_AP_a_avg = zeros(length(w_b_a),length(w_c_a),length(lambda_gen));
assoc_STA_E_a_avg = zeros(length(w_b_a),length(w_c_a),length(lambda_gen));

%OPTION B: WITH Extenders (To choose)
S_T_b = S_T_a;
E_T_b = E_T_a;
E_T_ok_b = E_T_ok_a;
D_avg_b = D_avg_a;
D_max_b = D_max_a;
SS_avg_b = SS_avg_a;
SS_min_b = SS_min_a;
assoc_STA_b = assoc_STA_a;
assoc_STA_AP_b = assoc_STA_AP_a;
assoc_STA_E_b = assoc_STA_E_a;

S_T_b_avg = S_T_a_avg;
E_T_b_avg = E_T_a_avg;
share_ok_b = share_ok_a;
D_avg_b_avg = D_avg_a_avg;
D_max_b_avg = D_max_a_avg;
SS_avg_b_avg = SS_avg_a_avg;
SS_min_b_avg = SS_min_a_avg;
assoc_STA_b_avg = assoc_STA_a_avg;
assoc_STA_AP_b_avg = assoc_STA_AP_a_avg;
assoc_STA_E_b_avg = assoc_STA_E_a_avg;

%OPTION C: WITH Extenders (To choose)
S_T_c = S_T_a;
E_T_c = E_T_a;
E_T_ok_c = E_T_ok_a;
D_avg_c = D_avg_a;
D_max_c = D_max_a;
SS_avg_c = SS_avg_a;
SS_min_c = SS_min_a;
assoc_STA_c = assoc_STA_a;
assoc_STA_AP_c = assoc_STA_AP_a;
assoc_STA_E_c = assoc_STA_E_a;

S_T_c_avg = S_T_a_avg;
E_T_c_avg = E_T_a_avg;
share_ok_c = share_ok_a;
D_avg_c_avg = D_avg_a_avg;
D_max_c_avg = D_max_a_avg;
SS_avg_c_avg = SS_avg_a_avg;
SS_min_c_avg = SS_min_a_avg;
assoc_STA_c_avg = assoc_STA_a_avg;
assoc_STA_AP_c_avg = assoc_STA_AP_a_avg;
assoc_STA_E_c_avg = assoc_STA_E_a_avg;

%OPTION D: WITH Extenders (To choose)
S_T_d = S_T_a;
E_T_d = E_T_a;
E_T_ok_d = E_T_ok_a;
D_avg_d = D_avg_a;
D_max_d = D_max_a;
SS_avg_d = SS_avg_a;
SS_min_d = SS_min_a;
assoc_STA_d = assoc_STA_a;
assoc_STA_AP_d = assoc_STA_AP_a;
assoc_STA_E_d = assoc_STA_E_a;

S_T_d_avg = S_T_a_avg;
E_T_d_avg = E_T_a_avg;
share_ok_d = share_ok_a;
D_avg_d_avg = D_avg_a_avg;
D_max_d_avg = D_max_a_avg;
SS_avg_d_avg = SS_avg_a_avg;
SS_min_d_avg = SS_min_a_avg;
assoc_STA_d_avg = assoc_STA_a_avg;
assoc_STA_AP_d_avg = assoc_STA_AP_a_avg;
assoc_STA_E_d_avg = assoc_STA_E_a_avg;

%OPTION E: WITHOUT Extenders
S_T_e = S_T_a;
E_T_e = E_T_a;
E_T_ok_e = E_T_ok_a;
D_avg_e = D_avg_a;
D_max_e = D_max_a;
SS_avg_e = SS_avg_a;
SS_min_e = SS_min_a;
assoc_STA_e = assoc_STA_a;
assoc_STA_AP_e = assoc_STA_AP_a;
assoc_STA_E_e = assoc_STA_E_a;

S_T_e_avg = S_T_a_avg;
E_T_e_avg = E_T_a_avg;
share_ok_e = share_ok_a;
D_avg_e_avg = D_avg_a_avg;
D_max_e_avg = D_max_a_avg;
SS_avg_e_avg = SS_avg_a_avg;
SS_min_e_avg = SS_min_a_avg;
assoc_STA_e_avg = assoc_STA_a_avg;
assoc_STA_AP_e_avg = assoc_STA_AP_a_avg;
assoc_STA_E_e_avg = assoc_STA_E_a_avg;

S_T_e_fixed = zeros(1,length(lambda_gen));
E_T_e_fixed = zeros(1,length(lambda_gen));
E_T_ok_e_fixed = zeros(1,length(lambda_gen));
D_avg_e_fixed = zeros(1,length(lambda_gen));
D_max_e_fixed = zeros(1,length(lambda_gen));
SS_avg_e_fixed = zeros(1,length(lambda_gen));
SS_min_e_fixed = zeros(1,length(lambda_gen));
assoc_STA_e_fixed = zeros(1,length(lambda_gen));
assoc_STA_AP_e_fixed = zeros(1,length(lambda_gen));
assoc_STA_E_e_fixed = zeros(1,length(lambda_gen));

%% LEGEND NAMING

switch score_mode_a
    case 0
        str_a = "WITH " + exts_a + " Extenders (RSSI-based)";
     
    case 1
        str_a = "WITH " + exts_a + " Extenders (Hops & children)";
        
    case 2
        str_a = "WITH " + exts_a + " Extenders (optimized) (" + kv_share_a + "%)";
        
    case 3
        str_a = "WITH " + exts_a + " Extenders (threshold-based) (" + kv_share_a + "%)";
        
    case 4
        str_a = "WITH " + exts_a + " Extenders (load aware) (" + kv_share_a + "%)";
        
    case 5
        str_a = "WITH " + exts_a + " Extenders (latency-based) (" + kv_share_a + "%)";
        
    otherwise
        str_a = "ERROR";
end

switch score_mode_b
    case 0
        str_b = "WITH " + exts_b + " Extenders (RSSI-based)";
        
    case 1
        str_b = "WITH " + exts_b + " Extenders (Hops & children)";
        
    case 2
        str_b = "WITH " + exts_b + " Extenders (optimized) (" + kv_share_b + "%)";
        
    case 3
        str_b = "WITH " + exts_b + " Extenders (threshold-based) (" + kv_share_b + "%)";
        
    case 4
        str_b = "WITH " + exts_b + " Extenders (load aware) (" + kv_share_b + "%)";

    case 5
        str_b = "WITH " + exts_b + " Extenders (latency-based) (" + kv_share_b + "%)";
        
    otherwise
        str_b = "ERROR";
end

switch score_mode_c
    case 0
        str_c = "WITH " + exts_c + " Extenders (RSSI-based)";
        
    case 1
        str_c = "WITH " + exts_c + " Extenders (Hops & children)";
        
    case 2
        str_c = "WITH " + exts_c + " Extenders (optimized) (" + kv_share_c + "%)";
        
    case 3
        str_c = "WITH " + exts_c + " Extenders (threshold-based) (" + kv_share_c + "%)";
        
    case 4
        str_c = "WITH " + exts_c + " Extenders (load aware) (" + kv_share_c + "%)";
 
    case 5
        str_c = "WITH " + exts_c + " Extenders (latency-based) (" + kv_share_c + "%)";
        
    otherwise
        str_c = "ERROR";
end

switch score_mode_d
    case 0
        str_d = "WITH " + exts_d + " Extenders (RSSI-based)";
        
    case 1
        str_d = "WITH " + exts_d + " Extenders (Hops & children)";
        
    case 2
        str_d = "WITH " + exts_d + " Extenders (optimized) (" + kv_share_d + "%)";
        
    case 3
        str_d = "WITH " + exts_d + " Extenders (threshold-based) (" + kv_share_d + "%)";
        
    case 4
        str_d = "WITH " + exts_d + " Extenders (load aware) (" + kv_share_d + "%)";

    case 5
        str_d = "WITH " + exts_d + " Extenders (latency-based) (" + kv_share_d + "%)";        
        
    otherwise
        str_d = "ERROR";
end

%% ALGORITHM EXECUTION

for k = 1:num_it
    
    % Random distribution of channels
    if (random_ch == 1)
        channel_R_a = ChannelDist(f_access,dev_a);
        channel_R_b = ChannelDist(f_access,dev_b);
        channel_R_c = ChannelDist(f_access,dev_c);
        channel_R_d = ChannelDist(f_access,dev_d);    
        channel_R_e = ChannelDist(f_access,dev_e);
    end
    
    % Allocation of channels into M matrix
    M_a(:,8) = transpose(channel_R_a);
    M_b(:,8) = transpose(channel_R_b);
    M_c(:,8) = transpose(channel_R_c);
    M_d(:,8) = transpose(channel_R_d);
    M_e(1,8) = transpose(channel_R_e);
    
    % N = [posX    posY    Parent_Index    Channel     Rate    Lambda  DBPS     Type    Score_mode]
    %      1       2       3               4           5       6       7        8       9
    N_a = zeros(sta,9);                 % WITH Extenders (To choose)
    
    %STA position
    if (random_pos == 1)
        if (deploy == 0)                %Deployment: circle
            pos_STA = PosGeneratorCircle(pos_AP,sta,R,margin_over,margin_under);
        else                            %Deployment: rectangle
            pos_STA = PosGeneratorRectangle([25 0],sta,side_h,side_v);
        end
    end
    
    % Allocation of positions into N matrix
    N_a(:,1) = pos_STA(:,1);
    N_a(:,2) = pos_STA(:,2);
    
    %Copy STA matrix
    N_b = N_a;
    N_c = N_a;
    N_d = N_a;
    N_e = N_a;
    
    %STA score mode
    [N_a(:,8),N_a(:,9)] = kvGenerator(sta,kv_share_a,score_mode_a);
    [N_b(:,8),N_b(:,9)] = kvGenerator(sta,kv_share_b,score_mode_b);
    [N_c(:,8),N_c(:,9)] = kvGenerator(sta,kv_share_c,score_mode_c);
    [N_d(:,8),N_d(:,9)] = kvGenerator(sta,kv_share_d,score_mode_d);
    
    %SVM-based feed data
%     for p = 1:sta
%         for q = 1:dev
%             dist(p,q,k) = sqrt((N_a(p,1)-M_a(q,1)).^2+(N_a(p,2)-M_a(q,2)).^2);
%         end
%     end
    
    %Code loop
    for l = 1:length(lambda_gen)
        
        m = 0;
        
        % Traffic model
        if (random_traffic == 0)
            N_a(:,6) = lambda_gen(l);
        else
            for p = 1:sta
                N_a(p,6) = eps_gen.*randn() + lambda_gen(l);
            end
        end
        
        N_b(:,6) = N_a(:,6);
        N_c(:,6) = N_a(:,6);
        N_d(:,6) = N_a(:,6);
        N_e(:,6) = N_a(:,6);
        
        % OPTION E: WITHOUT Extenders
        % (w_a, w_b(i) and w_c(j) are set to 0 as they do not affect to the network without Extenders)               
        [S_T_e_fixed(l),E_T_e_fixed(l),E_T_ok_e_fixed(l),D_avg_e_fixed(l),D_max_e_fixed(l),SS_avg_e_fixed(l),SS_min_e_fixed(l),assoc_STA_e_fixed(l)] = WIFIXComputing(map_R,map_STA,M_e,N_e,WIFI_std,f_backbone,f_access,PL_backbone,PL_access,Pt,Sens,L,TPHY,SIFS,DIFS,Tslot,ext_conn_alg,margin_R,max_R_per_R,score_mode_e,max_STA_per_R,0,0,0,channel_load_ext);
        
        for i = 1:length(w_b_a)
            for j = 1:length(w_c_a)
                
                if (score_mode_a == 4)
                    w_c_a(j) = 1 - w_b_a(i);
                end
                
                if (score_mode_b == 4)
                    w_c_b(j) = 1 - w_b_b(i);
                end
                
                if (score_mode_c == 4)
                    w_c_c(j) = 1 - w_b_c(i);
                end
                
                if (score_mode_d == 4)
                    w_c_d(j) = 1 - w_b_d(i);
                end
                
                m = m + 1;
                disp('*********************************************************');
                disp(['STA DEPLOYMENT (',num2str(k),'/',num2str(num_it),')']);
                disp(['TRAFFIC: ',num2str(l),'/',num2str(length(lambda_gen))]);
                disp(['--> Lambda/STA: ',num2str(lambda_gen(l)),' paq/s']);
                disp(['--> Total network traffic: ',num2str(lambda_gen(l)*sta*L/1e6),' Mbps']);
                disp(['WEIGHT CONFIGURATION: ',num2str(m),'/',num2str(length(w_b_a)*length(w_c_a))]);
                disp(['--> Option A: w_b = ',num2str(w_b_a(i)),' w_c = ',num2str(w_c_a(j))]);
                disp(str_a)
                disp(['--> Option B: w_b = ',num2str(w_b_b(i)),' w_c = ',num2str(w_c_b(j))]);
                disp(str_b)
                disp(['--> Option C: w_b = ',num2str(w_b_c(i)),' w_c = ',num2str(w_c_c(j))]);
                disp(str_c)
                disp(['--> Option D: w_b = ',num2str(w_b_d(i)),' w_c = ',num2str(w_c_d(j))]);
                disp(str_d)
                  
                %OPTION A: WITH Extenders (To choose)
                [S_T_a(i,j,k,l),E_T_a(i,j,k,l),E_T_ok_a(i,j,k,l),D_avg_a(i,j,k,l),D_max_a(i,j,k,l),SS_avg_a(i,j,k,l),SS_min_a(i,j,k,l),assoc_STA_a(i,j,k,l),assoc_STA_AP_a(i,j,k,l),assoc_STA_E_a(i,j,k,l)] = WIFIXComputing(map_R,map_STA,M_a,N_a,WIFI_std,f_backbone,f_access,PL_backbone,PL_access,Pt,Sens,L,TPHY,SIFS,DIFS,Tslot,ext_conn_alg,margin_R,max_R_per_R,score_mode_a,max_STA_per_R,w_a_a,w_b_a(i),w_c_a(j),channel_load_ext);
                
                %OPTION B: WITH Extenders (To choose)
                [S_T_b(i,j,k,l),E_T_b(i,j,k,l),E_T_ok_b(i,j,k,l),D_avg_b(i,j,k,l),D_max_b(i,j,k,l),SS_avg_b(i,j,k,l),SS_min_b(i,j,k,l),assoc_STA_b(i,j,k,l),assoc_STA_AP_b(i,j,k,l),assoc_STA_E_b(i,j,k,l)] = WIFIXComputing(map_R,map_STA,M_b,N_b,WIFI_std,f_backbone,f_access,PL_backbone,PL_access,Pt,Sens,L,TPHY,SIFS,DIFS,Tslot,ext_conn_alg,margin_R,max_R_per_R,score_mode_b,max_STA_per_R,w_a_b,w_b_b(i),w_c_b(j),channel_load_ext);
                
                %OPTION C: WITH Extenders (To choose)
                [S_T_c(i,j,k,l),E_T_c(i,j,k,l),E_T_ok_c(i,j,k,l),D_avg_c(i,j,k,l),D_max_c(i,j,k,l),SS_avg_c(i,j,k,l),SS_min_c(i,j,k,l),assoc_STA_c(i,j,k,l),assoc_STA_AP_c(i,j,k,l),assoc_STA_E_c(i,j,k,l)] = WIFIXComputing(map_R,map_STA,M_c,N_c,WIFI_std,f_backbone,f_access,PL_backbone,PL_access,Pt,Sens,L,TPHY,SIFS,DIFS,Tslot,ext_conn_alg,margin_R,max_R_per_R,score_mode_c,max_STA_per_R,w_a_c,w_b_c(i),w_c_c(j),channel_load_ext);
                
                %OPTION D: WITH Extenders (To choose)
                [S_T_d(i,j,k,l),E_T_d(i,j,k,l),E_T_ok_d(i,j,k,l),D_avg_d(i,j,k,l),D_max_d(i,j,k,l),SS_avg_d(i,j,k,l),SS_min_d(i,j,k,l),assoc_STA_d(i,j,k,l),assoc_STA_AP_d(i,j,k,l),assoc_STA_E_d(i,j,k,l)] = WIFIXComputing(map_R,map_STA,M_d,N_d,WIFI_std,f_backbone,f_access,PL_backbone,PL_access,Pt,Sens,L,TPHY,SIFS,DIFS,Tslot,ext_conn_alg,margin_R,max_R_per_R,score_mode_d,max_STA_per_R,w_a_d,w_b_d(i),w_c_d(j),channel_load_ext);
                                
                %OPTION E: WITHOUT Extenders
                S_T_e(i,j,k,l) = S_T_e_fixed(l);
                E_T_e(i,j,k,l) = E_T_e_fixed(l);
                E_T_ok_e(i,j,k,l) = E_T_ok_e_fixed(l);
                D_avg_e(i,j,k,l) = D_avg_e_fixed(l);
                D_max_e(i,j,k,l) = D_max_e_fixed(l);
                SS_avg_e(i,j,k,l) = SS_avg_e_fixed(l);
                SS_min_e(i,j,k,l) = SS_min_e_fixed(l);
                assoc_STA_e(i,j,k,l) = assoc_STA_e_fixed(l);
                assoc_STA_AP_e(i,j,k,l) = assoc_STA_AP_e_fixed(l);
                assoc_STA_E_e(i,j,k,l) = assoc_STA_E_e_fixed(l);

            end
        end
    end
end

%Computing averages for the num_rep performed simulations
for i = 1:length(w_b_a)
    for j = 1:length(w_c_a)
        for l = 1:length(lambda_gen)
            %OPTION A: WITH Extenders (To choose)
            [S_T_a_avg(i,j,l),E_T_a_avg(i,j,l),share_ok_a(i,j,l),D_avg_a_avg(i,j,l),D_max_a_avg(i,j,l),SS_avg_a_avg(i,j,l),SS_min_a_avg(i,j,l),assoc_STA_a_avg(i,j,l),assoc_STA_AP_a_avg(i,j,l),assoc_STA_E_a_avg(i,j,l)] = MeanGenerator(S_T_a(i,j,:,l),E_T_a(i,j,:,l),E_T_ok_a(i,j,:,l),D_avg_a(i,j,:,l),D_max_a(i,j,:,l),SS_avg_a(i,j,:,l),SS_min_a(i,j,:,l),assoc_STA_a(i,j,:,l),assoc_STA_AP_a(i,j,:,l),assoc_STA_E_a(i,j,:,l),num_it);
                        
            %OPTION B: WITH Extenders (To choose)
            [S_T_b_avg(i,j,l),E_T_b_avg(i,j,l),share_ok_b(i,j,l),D_avg_b_avg(i,j,l),D_max_b_avg(i,j,l),SS_avg_b_avg(i,j,l),SS_min_b_avg(i,j,l),assoc_STA_b_avg(i,j,l),assoc_STA_AP_b_avg(i,j,l),assoc_STA_E_b_avg(i,j,l)] = MeanGenerator(S_T_b(i,j,:,l),E_T_b(i,j,:,l),E_T_ok_b(i,j,:,l),D_avg_b(i,j,:,l),D_max_b(i,j,:,l),SS_avg_b(i,j,:,l),SS_min_b(i,j,:,l),assoc_STA_b(i,j,:,l),assoc_STA_AP_b(i,j,:,l),assoc_STA_E_b(i,j,:,l),num_it);
            
            %OPTION C: WITH Extenders (To choose)
            [S_T_c_avg(i,j,l),E_T_c_avg(i,j,l),share_ok_c(i,j,l),D_avg_c_avg(i,j,l),D_max_c_avg(i,j,l),SS_avg_c_avg(i,j,l),SS_min_c_avg(i,j,l),assoc_STA_c_avg(i,j,l),assoc_STA_AP_c_avg(i,j,l),assoc_STA_E_c_avg(i,j,l)] = MeanGenerator(S_T_c(i,j,:,l),E_T_c(i,j,:,l),E_T_ok_c(i,j,:,l),D_avg_c(i,j,:,l),D_max_c(i,j,:,l),SS_avg_c(i,j,:,l),SS_min_c(i,j,:,l),assoc_STA_c(i,j,:,l),assoc_STA_AP_c(i,j,:,l),assoc_STA_E_c(i,j,:,l),num_it);
                        
            %OPTION D: WITH Extenders (To choose)
            [S_T_d_avg(i,j,l),E_T_d_avg(i,j,l),share_ok_d(i,j,l),D_avg_d_avg(i,j,l),D_max_d_avg(i,j,l),SS_avg_d_avg(i,j,l),SS_min_d_avg(i,j,l),assoc_STA_d_avg(i,j,l),assoc_STA_AP_d_avg(i,j,l),assoc_STA_E_d_avg(i,j,l)] = MeanGenerator(S_T_d(i,j,:,l),E_T_d(i,j,:,l),E_T_ok_d(i,j,:,l),D_avg_d(i,j,:,l),D_max_d(i,j,:,l),SS_avg_d(i,j,:,l),SS_min_d(i,j,:,l),assoc_STA_d(i,j,:,l),assoc_STA_AP_d(i,j,:,l),assoc_STA_E_d(i,j,:,l),num_it);
                       
            %OPTION E: WITHOUT Extenders
            [S_T_e_avg(i,j,l),E_T_e_avg(i,j,l),share_ok_e(i,j,l),D_avg_e_avg(i,j,l),D_max_e_avg(i,j,l),SS_avg_e_avg(i,j,l),SS_min_e_avg(i,j,l),assoc_STA_e_avg(i,j,l),assoc_STA_AP_e_avg(i,j,l),assoc_STA_E_e_avg(i,j,l)] = MeanGenerator(S_T_e(i,j,:,l),E_T_e(i,j,:,l),E_T_ok_e(i,j,:,l),D_avg_e(i,j,:,l),D_max_e(i,j,:,l),SS_avg_e(i,j,:,l),SS_min_e(i,j,:,l),assoc_STA_e(i,j,:,l),assoc_STA_AP_e(i,j,:,l),assoc_STA_E_e(i,j,:,l),num_it);

        end
    end
end

%% PLOTS

%3D Option
if ((length(w_b_a) > 1) && (length(w_c_a) > 1))
    disp('Printing 3D option');
    for l = 1:length(lambda_gen)
        % Thoughput efficiency [AP]
        figure
        surf(E_T_a_avg(:,:,l))
        hold
        surf(E_T_b_avg(:,:,l))
        surf(E_T_c_avg(:,:,l))
        surf(E_T_d_avg(:,:,l))
        surf(E_T_e_avg(:,:,l))
        title(['Thoughput efficiency [AP] (with {\lambda} = ',num2str(lambda_gen(l)),' paq/s)'])
        xlabel('c')
        ylabel('b')
        xticks(1:w_c_a(end))
        yticks(1:w_b_a(end))
        xticklabels(w_c_a)
        yticklabels(w_b_a)
        legend(str_a,str_b,str_c,str_d,'WITHOUT Extenders')
        
        % Average delay [STA]
        figure
        surf(D_avg_a_avg(:,:,l))
        hold
        surf(D_avg_b_avg(:,:,l))
        surf(D_avg_c_avg(:,:,l))
        surf(D_avg_d_avg(:,:,l))
        surf(D_avg_e_avg(:,:,l))
        title(['Average delay [STA] (with {\lambda} = ',num2str(lambda_gen(l)),' paq/s)'])
        xlabel('c')
        ylabel('b')
        xticks(1:w_c_a(end))
        yticks(1:w_b_a(end))
        xticklabels(w_c_a)
        yticklabels(w_b_a)
        legend(str_a,str_b,str_c,str_d,'WITHOUT Extenders')
        
        % Maximum delay [STA]
        figure
        surf(D_max_a_avg(:,:,l))
        hold
        surf(D_max_b_avg(:,:,l))
        surf(D_max_c_avg(:,:,l))
        surf(D_max_d_avg(:,:,l))
        surf(D_max_e_avg(:,:,l))
        title(['Maximum delay [STA] (with {\lambda} = ',num2str(lambda_gen(l)),' paq/s)'])
        xlabel('c')
        ylabel('b')
        xticks(1:w_c_a(end))
        yticks(1:w_b_a(end))
        xticklabels(w_c_a)
        yticklabels(w_b_a)
        legend(str_a,str_b,str_c,str_d,'WITHOUT Extenders')
        
        % Number of associated STAs (%)
        figure
        surf((assoc_STA_a_avg(:,:,l)/sta)*100)
        hold
        surf((assoc_STA_b_avg(:,:,l)/sta)*100)
        surf((assoc_STA_c_avg(:,:,l)/sta)*100)
        surf((assoc_STA_d_avg(:,:,l)/sta)*100)
        surf((assoc_STA_e_avg(:,:,l)/sta)*100)
        title(['Associated STAs (%) (with {\lambda} = ',num2str(lambda_gen(l)),' paq/s)'])
        xlabel('c')
        ylabel('b')
        xticks(1:w_c_a(end))
        yticks(1:w_b_a(end))
        xticklabels(w_c_a)
        yticklabels(w_b_a)
        legend(str_a,str_b,str_c,str_d,'WITHOUT Extenders')
        
        % Non-congested simulations(%)
        figure
        surf(share_ok_a(:,:,l));
        hold
        surf(share_ok_b(:,:,l));
        surf(share_ok_c(:,:,l));
        surf(share_ok_d(:,:,l));
        surf(share_ok_e(:,:,l));
        title(['Non-congested simulations (%) (with {\lambda} = ',num2str(lambda_gen(l)),' paq/s)'])
        xlabel('c')
        ylabel('b')
        xticks(1:w_c_a(end))
        yticks(1:w_b_a(end))
        xticklabels(w_c_a)
        yticklabels(w_b_a)
        legend(str_a,str_b,str_c,str_d,'WITHOUT Extenders')
    end
end

%2.5D Option
if ((length(w_b_a) > 1) && (length(w_c_a) == 1) && (length(lambda_gen) > 1))
    disp('Printing 2.5D option');
    
    E_T_e_new = zeros(1,length(lambda_gen));
    D_avg_e_new = zeros(1,length(lambda_gen));
    D_max_e_new = zeros(1,length(lambda_gen));
    assoc_STA_e_new = zeros(1,length(lambda_gen));
    share_ok_e_new = zeros(1,length(lambda_gen));
    
    for i=1:length(lambda_gen)
        E_T_e_new(i) = E_T_e_avg(1,1,i);
        D_avg_e_new(i) = D_avg_e_avg(1,1,i);
        D_max_e_new(i) = D_max_e_avg(1,1,i);
        assoc_STA_e_new(i) = assoc_STA_e_avg(1,1,i);
        share_ok_e_new(i) = share_ok_e(1,1,i);
    end
    
    str = "WITH " + exts_a + " Extenders (load aware) (" + kv_share_a + "%) (\alpha = " + w_b_a(1) + " )";
    for i=2:length(w_b_a)
        new = "WITH " + exts_a + " Extenders (load aware) (" + kv_share_a + "%) (\alpha = " + w_b_a(i) + " )";
        str = [str new];
    end
    
    for i=1:length(w_b_b)
        new = "WITH " + exts_b + " Extenders (load aware) (" + kv_share_b + "%) (\alpha = " + w_b_b(i) + " )";
        str = [str new]; 
    end
    
    for i=1:length(w_b_c)
        new = "WITH " + exts_c + " Extenders (load aware) (" + kv_share_c + "%) (\alpha = " + w_b_c(i) + " )";
        str = [str new];
    end
    
    for i=1:length(w_b_d)
        new = "WITH " + exts_d + " Extenders (load aware) (" + kv_share_d + "%) (\alpha = " + w_b_d(i) + " )";
        str = [str new];
    end
    
    % Thoughput efficiency [AP]
    figure
    plot((lambda_gen*sta*L)/1e6,reshape(E_T_a_avg,length(w_b_a),length(lambda_gen)).*(lambda_gen.*sta.*L)./1e8)    
    hold
    plot((lambda_gen*sta*L)/1e6,reshape(E_T_b_avg,length(w_b_b),length(lambda_gen)).*(lambda_gen.*sta.*L)./1e8) 
    plot((lambda_gen*sta*L)/1e6,reshape(E_T_c_avg,length(w_b_c),length(lambda_gen)).*(lambda_gen.*sta.*L)./1e8) 
    plot((lambda_gen*sta*L)/1e6,reshape(E_T_d_avg,length(w_b_d),length(lambda_gen)).*(lambda_gen.*sta.*L)./1e8) 
    plot((lambda_gen*sta*L)/1e6,(E_T_e_new./100).*(lambda_gen.*sta.*L)./1e6)
    
    title('Thoughput efficiency [AP]')
    xlabel('Total offered load (Mbps)')
    ylabel('Total Throughput (Mbps)')
    legend([str,'WITHOUT Extenders'])
    
    % Average delay [STA]
    figure
    plot((lambda_gen*sta*L)/1e6,reshape(D_avg_a_avg,length(w_b_a),length(lambda_gen)))
    hold
    plot((lambda_gen*sta*L)/1e6,reshape(D_avg_b_avg,length(w_b_a),length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(D_avg_c_avg,length(w_b_c),length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(D_avg_d_avg,length(w_b_d),length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,D_avg_e_new)
    
    title('Average delay [STA]')
    xlabel('Total offered load (Mbps)')
    ylabel('Delay (s)')
    legend([str,'WITHOUT Extenders'])
    
    % Maximum delay [STA]
    figure
    plot((lambda_gen*sta*L)/1e6,reshape(D_max_a_avg,length(w_b_a),length(lambda_gen)))
    hold
    plot((lambda_gen*sta*L)/1e6,reshape(D_max_b_avg,length(w_b_b),length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(D_max_c_avg,length(w_b_c),length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(D_max_d_avg,length(w_b_d),length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,D_max_e_new)
    
    title('Maximum delay (STA)')
    xlabel('Total offered load (Mbps)')
    ylabel('Delay (s)')
    legend([str,'WITHOUT Extenders'])
    
    % Number of associated STAs (%)
    figure
    plot((lambda_gen*sta*L)/1e6,reshape((assoc_STA_a_avg./sta).*100,length(w_b_a),length(lambda_gen)))
    hold
    plot((lambda_gen*sta*L)/1e6,reshape((assoc_STA_b_avg./sta).*100,length(w_b_b),length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape((assoc_STA_c_avg./sta).*100,length(w_b_c),length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape((assoc_STA_d_avg./sta).*100,length(w_b_d),length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,(assoc_STA_e_new./sta).*100)
    
    title('Association success')
    xlabel('Total offered load (Mbps)')
    ylabel('Associated STAs (%)')
    legend([str,'WITHOUT Extenders'])
    
    % Non-congested simulations(%)
    figure
    plot((lambda_gen*sta*L)/1e6,reshape(share_ok_a,length(w_b_a),length(lambda_gen)))
    hold
    plot((lambda_gen*sta*L)/1e6,reshape(share_ok_b,length(w_b_b),length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(share_ok_c,length(w_b_c),length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(share_ok_d,length(w_b_d),length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,share_ok_e_new)
    
    title('Non-congested simulations')
    xlabel('Total offered load (Mbps)')
    ylabel('Non-congested simulations (%)')
    legend([str,'WITHOUT Extenders'])
    
end

%2D Option
if ((length(w_b_a) == 1) && (length(w_c_a) == 1) && (length(lambda_gen) > 1))
    disp('Printing 2D option');
       
    % Thoughput efficiency [AP]
    figure
    plot((lambda_gen*sta*L)/1e6,reshape(E_T_a_avg,1,length(lambda_gen)).*(lambda_gen.*sta.*L)./1e8)
    hold
    plot((lambda_gen*sta*L)/1e6,reshape(E_T_b_avg,1,length(lambda_gen)).*(lambda_gen.*sta.*L)./1e8)
    plot((lambda_gen*sta*L)/1e6,reshape(E_T_c_avg,1,length(lambda_gen)).*(lambda_gen.*sta.*L)./1e8)
    plot((lambda_gen*sta*L)/1e6,reshape(E_T_d_avg,1,length(lambda_gen)).*(lambda_gen.*sta.*L)./1e8)  
    plot((lambda_gen*sta*L)/1e6,reshape(E_T_e_avg,1,length(lambda_gen)).*(lambda_gen.*sta.*L)./1e8)
    
    title('Thoughput efficiency [AP]')
    xlabel('Total network traffic (Mbps)')
    ylabel('Total Throughput (Mbps)')
    legend(str_a,str_b,str_c,str_d,'WITHOUT Extenders')
    
    % Average delay [STA]
    figure
    plot((lambda_gen*sta*L)/1e6,reshape(D_avg_a_avg,1,length(lambda_gen)))
    hold
    plot((lambda_gen*sta*L)/1e6,reshape(D_avg_b_avg,1,length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(D_avg_c_avg,1,length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(D_avg_d_avg,1,length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(D_avg_e_avg,1,length(lambda_gen)))
    
    title('Average delay [STA]')
    xlabel('Total network traffic (Mbps)')
    ylabel('Delay (s)')
    legend(str_a,str_b,str_c,str_d,'WITHOUT Extenders')
    
    % Maximum delay [STA]
    figure
    plot((lambda_gen*sta*L)/1e6,reshape(D_max_a_avg,1,length(lambda_gen)))
    hold
    plot((lambda_gen*sta*L)/1e6,reshape(D_max_b_avg,1,length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(D_max_c_avg,1,length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(D_max_d_avg,1,length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(D_max_e_avg,1,length(lambda_gen)))
    
    title('Maximum delay (STA)')
    xlabel('Total network traffic (Mbps)')
    ylabel('Delay (s)')
    legend(str_a,str_b,str_c,str_d,'WITHOUT Extenders')
    
    % Number of associated STAs (%)
    figure
    plot((lambda_gen*sta*L)/1e6,reshape((assoc_STA_a_avg./sta).*100,1,length(lambda_gen)))
    hold
    plot((lambda_gen*sta*L)/1e6,reshape((assoc_STA_b_avg./sta).*100,1,length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape((assoc_STA_c_avg./sta).*100,1,length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape((assoc_STA_d_avg./sta).*100,1,length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape((assoc_STA_e_avg./sta).*100,1,length(lambda_gen)))
    
    title('Association success')
    xlabel('Total network traffic (Mbps)')
    ylabel('Associated STAs (%)')
    legend(str_a,str_b,str_c,str_d,'WITHOUT Extenders')
    
    % Non-congested simulations(%)
    figure
    plot((lambda_gen*sta*L)/1e6,reshape(share_ok_a,1,length(lambda_gen)))
    hold
    plot((lambda_gen*sta*L)/1e6,reshape(share_ok_b,1,length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(share_ok_c,1,length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(share_ok_d,1,length(lambda_gen)))
    plot((lambda_gen*sta*L)/1e6,reshape(share_ok_e,1,length(lambda_gen)))
    
    title('Non-congested simulations')
    xlabel('Total network traffic (Mbps)')
    ylabel('Non-congested simulations (%)')
    legend(str_a,str_b,str_c,str_d,'WITHOUT Extenders')
end
