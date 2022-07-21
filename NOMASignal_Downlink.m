%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Creating NOMA Downlink signal depending on channel of users 
%        in uplink, taken from CellFreeSystem function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [R_NOMA , R_OMA] = NOMASignal_Downlink(N_ue , PL , Eta , Eta_sqroot, Eta_OMA , Eta_OMA_sqroot)

% Total Transmit power of AP in mW
P_ap = 200;

% Noise power= To (kelvin)* k (boltzman constant) * noise_figure in mW
No = 290 * 1.381 * (10^-23) * (10^0.9) * 10^3; % noise power for unit bandwidth

%             Number of clusters = Number of orthogonal pilots
% Length of coherence interval
tau = 196;
% Length of pilot sequence = Number of clusters 
tau_p = N_ue/2;            

% Give the main cluster 70% of the AP power, while other clusters take 30%
P_mainCluster = 0.55 * P_ap;
P_clusters = 0.45 * P_ap;    % power of remaining clusters

%% Assuming 2-users/cluster, we need to use 2-scaling factors
   %             a1 = 0.3   ,  a2 = 0.7
   
 % P_a is a vector representing allocated power (P_allocated) for each user
P_a = ones(2,1);
for i = 1:1:2
    if i==1
        P_a(i,1) = 0.3  * P_mainCluster; % Intra-cluster interference
    else 
        P_a(i,1) = 0.7  * P_mainCluster;  % Desired signal/user
%    else 
%        P_a(i,1) = 0.50 * P_a(i,1); % Imperfect SIC error
    end
end


 %% Desired signal of user (k), Intracluster interference (IA_k), and
            % intercluster interference of nearest user

% Matrix holding the difference between actual path-loss & estimated PL
             Diff_PL_Eta = PL - ((pi/4) .* Eta);
   % Difference matrix for OMA analysis
             Diff_PL_EtaOMA =  PL - ((pi/4) .* Eta_OMA);
 
% Desired signal component
           DS_k1 = P_a(1,1)* (pi/4) * (sum(Eta_sqroot(1,1:end))^2) ;
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Desired signal for OMA system
     DS_k1oma = P_a(1,1)* (pi/4) * (sum(Eta_OMA_sqroot(1,1:end))^2) ;

% 1st interference component as a result of pre detection of received
            % signal with statistical CSI
          FirstInt_comp_k1 = P_a(1,1) * sum(Diff_PL_Eta(1,1:end));
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Repeating the same result for OMA Rate
         FirstInt_comp_k1oma = P_a(1,1) * sum(Diff_PL_EtaOMA(1,1:end));
          
% Intra-cluster interference resulting from nearest UE to AP
%       Intra_k = P_a(1,1) * ((pi/4) * sum(Eta_sqroot(2,1:end))^2 + sum(Diff_PL_Eta(2,1:end)));
   
% Inter-cluster interference of users in other clusters 
      Inter_k1 = P_clusters * sum(PL(1,1:end));% Inter-cluster interference from other clusters/users outside main cluster
      

% Imperfect SIC resulting from poor detection of farthest UE to AP
p = 0.1; % correlation coefficient between transmitted symbol and estimated one
Corr_CF = (pi/2) * (1-p); % Imperfect SIC coefficient to be multiplied
ISIC_k1 = P_a(2,1) * (sum(Diff_PL_Eta(1,1:end)) + Corr_CF * sum(Eta_sqroot(1,1:end)).^2);


%% Desired signal of user (k), Intracluster interference (IA_k), and
            % intercluster interference of farthest user
% Desired signal component
           DS_k2 = P_a(2,1)* (pi/4) * (sum(Eta_sqroot(2,1:end))^2) ;
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Desired signal for OMA system
     DS_k2oma = P_a(2,1)* (pi/4) * (sum(Eta_OMA_sqroot(2,1:end))^2) ;
           
% 1st interference component as a result of pre detection of received
            % signal with statistical CSI
          FirstInt_comp_k2 = P_a(2,1) * sum(Diff_PL_Eta(2,1:end));
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          FirstInt_comp_k2oma = P_a(2,1) * sum(Diff_PL_EtaOMA(2,1:end));

% Intra-cluster interference resulting from nearest UE to AP
       Intra_k2 = P_a(1,1) * ((pi/4) * sum(Eta_sqroot(2,1:end))^2 + sum(Diff_PL_Eta(2,1:end)));
   
% Inter-cluster interference of users in other clusters 
      Inter_k2 = P_clusters * sum(PL(2,1:end));% Inter-cluster interference from other clusters/users outside main cluster
       
%% After evaluating each term, we divide DS_k, by the sum of other terms to get the achievable rate

% NOMA SINR to be used next to find R_NOMA
SINR_k1 = DS_k1 / (FirstInt_comp_k1 + Inter_k1 + ISIC_k1 + No);
SINR_k2 = DS_k2 / (FirstInt_comp_k2 + Inter_k2 + Intra_k2 + No);

% OMA SINR to be used next to find R_OMA
% SINR_OMA_k1 = DS_k1 / (FirstInt_comp_k1 +  Inter_k1 + No);
SINR_OMA_k1 = DS_k1oma / (FirstInt_comp_k1oma +  Inter_k1 + No);
% SINR_OMA_k2 = DS_k2 / (FirstInt_comp_k2 +  Inter_k2 + No);
SINR_OMA_k2 = DS_k2oma / (FirstInt_comp_k2oma +  Inter_k2 + No);

% Pre-log scale factor for NOMA and OMA
Scale_NOMA = (tau - tau_p)/tau;
Scale_OMA = (tau - 2*tau_p)/tau;

% NOMA Rate requirements for near and far users
R_k1 = Scale_NOMA * log2(1 + SINR_k1);
R_k2 = Scale_NOMA * log2(1 + SINR_k2);
% Rate of Main cluster is the sum of rates of both users in main cluster
R_main = R_k1 + R_k2;

% OMA Rate requirements for near and far users
R_OMA_main = log2(1 + SINR_OMA_k1) + log2(1 + SINR_OMA_k2);
R_OMA_main = Scale_OMA * R_OMA_main;

%%      Rate of the other clusters except the main cluster

% Number of clusters is equal to the number of allocated pilot symbols
nbrofcluster = tau_p;
% Power of each cluster
P_cl = P_clusters / nbrofcluster;
% Power allocated for each user for other clusters
P_othercl = [0.3 0.7]' * P_cl;

               %% Rate of Nearest user to AP for other clusters
% Desired signal component
DS_1 = P_othercl(1,1) * (pi/4) * (sum(Eta_sqroot(1,1:end))^2) ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DS_1OMA = P_othercl(1,1) * (pi/4) * (sum(Eta_OMA_sqroot(1,1:end))^2) ;

% First inteference component
FirstInt_comp_1 = P_othercl(1,1) * sum(Diff_PL_Eta(1,1:end));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FirstInt_comp_1OMA = P_othercl(1,1) * sum(Diff_PL_EtaOMA(1,1:end));

% Inter-cluster interference
Inter_1 = P_mainCluster * sum(PL(1,1:end));

% Imperfect Successive Interference Cancellation component
p = 0.1; % correlation coefficient between transmitted symbol and estimated one
Corr_CF = (pi/2) * (1-p); % Imperfect SIC coefficient to be multiplied
ISIC = P_othercl(1,1) * (sum(Diff_PL_Eta(1,1:end)) + Corr_CF * sum(Eta_sqroot(1,1:end)).^2);

% SINR of 1st user in other clusters
SINR_cl_1 = DS_1 / (FirstInt_comp_1 + Inter_1 + ISIC + No);
R_cl_1 = Scale_NOMA * log2(1 + SINR_cl_1);

% SINR_OMA_1 = DS_k1 / (FirstInt_comp_1 +  Inter_1 + No);
SINR_OMA_1 = DS_1OMA / (FirstInt_comp_1OMA +  Inter_1 + No);

R_oma_1 = Scale_OMA * log2(1 + SINR_OMA_1);

              %% Rate of far user to AP for other clusters
% Desired signal component for far user to AP                      
DS_2 = P_othercl(2,1) * (pi/4) * (sum(Eta_sqroot(2,1:end))^2) ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DS_2OMA = P_othercl(2,1) * (pi/4) * (sum(Eta_OMA_sqroot(2,1:end))^2) ;

% First interference component
FirstInt_comp_2 = P_othercl(2,1) * sum(Diff_PL_Eta(2,1:end));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FirstInt_comp_2OMA = P_othercl(2,1) * sum(Diff_PL_EtaOMA(2,1:end));

% Inter-cluster interference
Inter_2 = P_mainCluster * sum(PL(2,1:end));

% Intra-cluster inteference component
Intra = P_othercl(2,1) * ((pi/4) * sum(Eta_sqroot(1,1:end))^2 + sum(Diff_PL_Eta(1,1:end)));

% SINR of 2nd user in other clusters
SINR_cl_2 = DS_2 / (FirstInt_comp_2 + Inter_2 + Intra + No);
R_cl_2 = Scale_NOMA * log2(1 + SINR_cl_2);

% SINR_OMA_2 = DS_2 / (FirstInt_comp_2 +  Inter_2 + No);
SINR_OMA_2 = DS_2OMA / (FirstInt_comp_2OMA +  Inter_2 + No);
R_oma_2 = Scale_OMA * log2(1 + SINR_OMA_2);

%% Achievable rate = Rate_Main cluster   +    Rate_Other clusters
R_clusters_noma = (tau_p-1) * (R_cl_1 + R_cl_2);
R_NOMA = R_main + R_clusters_noma;

R_clusters_oma = (tau_p-1) * (R_oma_1 + R_oma_2);
R_OMA = R_OMA_main + R_clusters_oma;


end