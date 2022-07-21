%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Creating Cell-Free System with APs, UEs and their channels
%  M_ap : number of APs of the system, N_ue : number of User equipments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [PL] = CellFreeSystem (M_ap , N_ue)

%% Creating a CF-mMIMO in an area of 250m x 250m with users surrounded
       %by APs, which can be increased afterwards
       
% AP_pos for positions of the Access Points in the system region
AP_pos = zeros(M_ap,1);
for counter = 1:1:M_ap
    if counter == 1
        AP_pos(1,1) = 0 + 1i*0; %Put first AP at the origin point
    elseif counter <= 10 && counter > 1
        AP_pos(counter,1) = randi([10 50]) + 1i*randi([5 100]);
    elseif counter > 10 && counter <= 30
          AP_pos(counter,1) = randi([60 100]) + 1i*randi([5 100]);
    else
         AP_pos(counter,1) = randi([50 240]) + 1i*randi([5 240]);
    end
end


% UE_pos for positions of 9 users/N_ue with each 3-users close to an AP
UE_pos = zeros(N_ue,1);
for count=1:1:N_ue
    if count == 1 
            UE_pos(count,1) = randi([9 10],1,1) + 1i*randi([5 7],1,1);
%            UE_pos(count,1) = 5 + 1i * 4;
    elseif count == 2
            UE_pos(count,1) = randi([35 40],1,1) + 1i*randi([7 8],1,1);
%           UE_pos(count,1) = 15 + 1i * 4;
    else
            UE_pos(count,1) = randi([50 220],1,1) + 1i*randi([15 220],1,1);
    end      
end


%% Create a general matrix for path-loss of each user to each AP
PL = zeros(N_ue,M_ap);
for c=1:1:N_ue
    for q=1:1:M_ap
        dist = UE_pos(c,1) - AP_pos(q,1);
        PL(c,q) = norm(dist) ^ (-2);
        
    end
end


%% Use Hata-Cost Model for path loss of the transmitted signal
% f = 1900; % frequency is 1.9 GHz = 1900 MHz
% hght_ue = 15; % height of user antenna is 15 meters
% hght_ap = 65; % height of AP is 65 meters
% d1 = 50; % maximum distance between AP and UE
% d0 = 10; % minimum distance between AP and UE
% FSPL = 45.5 + 35.46 * log10(f) - 13.82 * log10(hght_ap) - 1.1 * hght_ue * log10(f) + 0.7 * hght_ue;
% Shd_fad = 10^(8/10);
% for i = 1:1:N_ue
%     for j = 1:1:M_ap
%         if PL(i,j) > d1
%            dist_log = FSPL + 35 * log(PL(i,j));
%            PL(i,j) = 10.^(-dist_log/10) * Shd_fad;
%         elseif PL(i,j) > d0 && PL(i,j) <= d1
%             dist_log = FSPL + 15 * log(d1) + 20 * log(PL(i,j,1));
%             PL(i,j) = 10.^(-dist_log/10) * Shd_fad;
%         else
%            dist_log = FSPL + 15 * log(d1) + 20 * log(d0);
%            PL(i,j) = 10.^(-dist_log/10) * Shd_fad;
%                 
%         end
%     end
% end



%% Generate a small-scale fading matrix of small-scale channels of
         % users to APs and vice versa assuming TDD protocol
h_ch = normrnd(0,1,N_ue,M_ap) + 1i*normrnd(0,1,N_ue,M_ap);%Circular symmetric gaussian

% Form the complete channel of each user to each AP as h_mnk=? * h
H_ch = sqrt(PL) .* h_ch; 
end


