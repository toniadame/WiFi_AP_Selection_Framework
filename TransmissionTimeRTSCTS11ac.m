% Packet Aggregation is not considered
% 11n i 11ac fan servir 52 data subcarriers

function [Ts,Tc] = TransmissionTimeRTSCTS11ac(L,DBPS,DBPSmin)

    Ts = 4E-6; % OFDM symbol
    
    DIFS = 34E-6; % validated
    SIFS = 16E-6; % validated 
    EmptySlot = 9E-6; % validated
    SuSS = 2; 
    
    L_RTS = 160; % validated
    L_CTS = 112; % validated
    L_ACK = 112; % validated
    L_MAC = 320; % validated    
    SF = 16; % validated
    TB = 6; % validated
    
    T_LegacyPreamble = 20E-6;
    T_HTPreamble = 16E-6+8*4E-6; % Worst case with 8 VHT-LTFs
    
    T_RTS = T_LegacyPreamble + ceil((SF+L_RTS+TB)/DBPSmin)*Ts;
    T_CTS = T_LegacyPreamble + ceil((SF+L_CTS+TB)/DBPSmin)*Ts;
    T_ACK = T_LegacyPreamble + ceil((SF+L_ACK+TB)/DBPSmin)*Ts;
    T_DATA = T_LegacyPreamble + T_HTPreamble + ceil((SF+L_MAC+L+TB)/(SuSS*DBPS))*Ts;
    
    Ts = T_RTS + SIFS + T_CTS + SIFS + T_DATA + SIFS + T_ACK + DIFS + EmptySlot;
    Tc = T_RTS + SIFS + T_CTS + DIFS + EmptySlot;
    
end