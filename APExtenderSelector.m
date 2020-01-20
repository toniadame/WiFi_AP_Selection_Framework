%-------------------------------------------------------------------------
% Channel load aware AP/Extender selection mechanism
%-------------------------------------------------------------------------
% APExtenderSelector.m --> Selects the best AP/Extender
%-------------------------------------------------------------------------

function S = APExtenderSelector(M,f_access,RSSI_map,Pt,Sens,L,TPHY,SIFS,DIFS,Tslot,score_mode,max_STA_per_R,w_a,w_b,w_c)

dev = size(M,1);
NC = 50000;       %Score of non-decoded packets (i.e., below Sens. level)
RSSI_pond = zeros(1,dev);
total_airtime_backbone = zeros(1,dev);
d_DBPS = zeros(1,dev);
d_rate = zeros(1,dev);
d_delay = zeros(1,dev);

% Check coverage range
for i = 1:dev
    if ((RSSI_map(i) < Sens) || (M(i,9) >= max_STA_per_R))
        RSSI_map(i) = NC;
    else
        RSSI_map(i) = -RSSI_map(i);
    end
end

RSSI_min = min(RSSI_map);

if (RSSI_min == NC)
    S = 0;
else
    S_list = find(RSSI_map == RSSI_min);
    S_1 = S_list(1);
    
    switch score_mode
        case 0
            % Traditional IEEE 802.11 RSSI-based
            S = S_1;
            
        case 1
            % Number of hops & number of children
            %S = -Pr + w_b.*M(k,3) + w_c.*M(k,9);
            Score = RSSI_map + w_b.*transpose(M(:,3)) + w_c.*transpose(M(:,9));
            Score_min = min(Score);
            S_list = find(Score == Score_min);
            S = S_list(1);
            
        case 2
            % Number of hops & Channel airtime of first link to Extender & Channel airtime of second link
            %S = -Pr + w_a.*M(k,3) + w_b.*M(k,12) + w_c.*M(k,13);
            Score = RSSI_map + w_a.*transpose(M(:,3)) + w_b.*transpose(M(:,12)) + w_c.*transpose(M(:,13));
            Score_min = min(Score);
            S_list = find(Score == Score_min);
            S = S_list(1);
            
        case 3
            % Threshold-based
            for i = 1:dev
                if ((M(i,12) >= (w_b/100)) || (M(i,13) >= (w_c/100)))
                    RSSI_map(i) = NC;
                end
                
                if ((RSSI_map(i) ~= NC) && (M(i,3) > 0))
                    RSSI_map(i) = RSSI_map(i) + M(i,3)*w_a;
                end
            end
            
            RSSI_min = min(RSSI_map);
            
            if (RSSI_min ~= NC)
                S_list = find(RSSI_map == RSSI_min);
                S = S_list(1);
            else
                disp('----------------------->No he encontrado a nadie en el metodo simplified');
                %S = S_1;
                S = 0;
            end
                        
        case 4
            %Load aware (paper)
            %S = -Pr* + w_b.*M(k,12) + w_c.*M(k,13) + total_airtime_backbone
                      
            for i = 1:dev
                
                if (((RSSI_map(i)) > -Pt) &&  ((RSSI_map(i)) <= -Sens))
                    RSSI_pond(i) = (Pt + RSSI_map(i))/(Pt - Sens);
                else
                    RSSI_pond(i) = NC;
                end
                
                if (M(i,5) > 1)     %This Extender is connected to another Extender
                    total_airtime_backbone(i) = M(M(i,5),13);
                end
            end

            Score = w_b.*(RSSI_pond + transpose(M(:,12))) + w_c.*(transpose(M(:,13)) + total_airtime_backbone);
            Score_min = min(Score);
            if (Score_min < NC)
                S_list = find(Score == Score_min);
                S = S_list(1);
            else
                disp('----------------------->No he encontrado a nadie en el metodo load aware');
                %S = S_1;
                S = 0;
            end
            
        case 5
            %End-to-end latency-based (paper)
                       
            if (RSSI_map(1) <= -w_a)
                S = 1;
            else
                for i = 1:dev
                    if (RSSI_map(i) ~= NC)
                        [d_DBPS(i),d_rate(i)] = RatesWIFI(-RSSI_map(i),Sens,f_access);
                        d_delay(i) = PacketDelay(L,TPHY,d_DBPS(i),SIFS,DIFS,Tslot);
                        d_delay(i) = d_delay(i) + M(i,6);
                    else
                        d_delay(i) = NC;
                    end
                end

                d_delay(1) = NC;
                min_delay = min(d_delay);
                S_list = find(d_delay == min_delay);
                
                if (length(S_list) > 1)
                    d_hops = transpose(M(S_list,3));
                    min_hops = min(d_hops);
                    S_list2 = find(d_hops == min_hops);
                    S = S_list(S_list2(1));
                else                                       
                    S = S_list(1);
                end
            end
            
        otherwise
            disp('Error')
    end
end
end