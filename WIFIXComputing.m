%-------------------------------------------------------------------------
% Channel load aware AP/Extender selection mechanism
%-------------------------------------------------------------------------
% WIFIXComputing.m --> Computation of the performance metrics in a network
%                      operating under the defined configuration
%-------------------------------------------------------------------------

function [S_T,E_T,E_T_ok,D_avg,D_max,SS_avg,SS_min,assoc_STA,assoc_STA_AP,assoc_STA_E] = WIFIXComputing(map_R,map_STA,M,N,WIFI_std,f_backbone,f_access,PL_backbone,PL_access,Pt,Sens,L,TPHY,SIFS,DIFS,Tslot,ext_conn_alg,margin_R,max_R_per_R,score_mode,max_STA_per_R,w_a,w_b,w_c,channel_load_ext)

%Sizes
sz = size(M);
dev = sz(1);

if (dev > 1)  %WITH EXTENDERS
    %disp('*********************************');
    %disp('Computing Topology of Extenders');
    [M] = TopologyExtenders(map_R,M,f_backbone,PL_backbone,Pt,Sens,L,TPHY,SIFS,DIFS,Tslot,ext_conn_alg,margin_R,max_R_per_R);
end

%disp('*********************************');
%disp('Computing Topology of Stations');
[M,N,routing_table,S_STA,D_STA,U_STA,A_STA,S_R,D_R,U_R,A_R] = TopologySTAs(map_STA,M,N,WIFI_std,f_backbone,f_access,PL_access,Pt,Sens,L,TPHY,SIFS,DIFS,Tslot,score_mode,max_STA_per_R,w_a,w_b,w_c,channel_load_ext);

%format shortG 
%M
%N
%routing_table

%Auxiliar variables
active_STA = find(N(:,5) ~= 0);

if (dev > 1)    %WITH EXTENDERS
    %More auxiliar variables
    direct_STA = transpose(find((N(:,3) == 1)));
    R_hop1 = find((M(:,3) == 1));
    
    %Performance metrics with Extenders
    S_T = sum(S_STA(direct_STA)) + sum(S_R(R_hop1));    %Total throughput
    E_T = S_T * 100/(sum(N(:,6)) * L);                  %Throughput efficiency
    E_T_ok = floor(E_T/100);                            %Flag if E_T == 100 %
    D_avg = mean(D_STA(active_STA));                    %Average Delay
    D_max = max(D_STA(active_STA));                     %Maximum Delay
    SS = S_STA./(transpose(N(:,6))*L)*100;              %Satisfaction (STA)
    SS_avg = mean(SS(active_STA));                      %Average Satisfaction
    SS_min = min(SS(active_STA));                       %Minimum Satisfaction
    assoc_STA = sum(N(:,3) ~= 0);                       %Associated STAs
    assoc_STA_AP = M(1,9);                              %Associated STAs to the AP
    assoc_STA_E = sum(M(2:dev,9))/(dev-1);              %Mean associated STAs to the Extenders
else            %WITHOUT EXTENDERS
    %Performance metrics without Extenders
    S_T = sum(S_STA(active_STA));                       %Total throughput
    E_T = S_T * 100/(sum(N(:,6)) * L);                  %Throughput efficiency
    E_T_ok = floor(E_T/100);                            %Flag if E_T == 100 %
    D_avg = mean(D_STA(active_STA));                    %Average Delay
    D_max = max(D_STA(active_STA));                     %Maximum Delay
    SS = S_STA./(transpose(N(:,6))*L)*100;              %Satisfaction (STA)
    SS_avg = mean(SS(active_STA));                      %Average Satisfaction
    SS_min = min(SS(active_STA));                       %Minimum Satisfaction
    assoc_STA = sum(N(:,3) ~= 0);                       %Associated STAs
    assoc_STA_AP = assoc_STA;                           %Associated STAs to the AP
    assoc_STA_E = 0;                                    %Mean associated STAs to the Extenders
end

end