%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Precoding function for getting MMSE estimates, then use them to
               % form the precoding matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Eta , Eta_sqroot , Eta_OMA , Eta_OMA_sqroot] = Precoding_ConjugateBF(M_ap, N_ue, PL)
% Each cluster has 3-users
     %  Userspercluster = 3; 

%                Number of clusters = Number of orthogonal pilots
% Length of coherence interval
tau = 196; 
% Length of pilot sequence = Number of clusters
%                    tau_p = 60;
tau_p = N_ue/2;

% Transmit power of UE in mW
P_ue = 100;
% Power of pilot sequence
P_pt = P_ue;
% Additive White Gaussian Noise component
%                 noise = sqrt(1/2) * (randn + 1i*randn);


%% Create an estimated channel matrix with path-loss coefficients
% H_MMSE = H_ch; 
Eta = PL .^ 2; % Estimated path-loss matrix will be derived from actual pathloss PL
Eta_OMA = PL .^ 2; % Estimated path-loss matrix for OMA Rate analysis

for count = 1:1:M_ap 
   sumPL = PL(1,count) + PL(2,count);
   MMSE_const = (tau_p * P_pt) / (1 + (tau_p * P_pt * sumPL));
   Eta(1:2,count) = MMSE_const .* Eta(1:2,count);
   
   for i = 1:1:2
      MMSE_constOMA = (2 * tau_p * P_pt) / (1 + (2 * tau_p * P_pt * PL(i,count)));
      Eta_OMA(i,count) = Eta_OMA(i,count) * MMSE_constOMA;
   end
   % Repeating same steps to get the MMSE estimated channel h_hat_mn
%    MMSE_const_ch = sqrt(tau_p * P_pt) / (1 + tau_p * P_pt * sumPL);
%    H_ch(1:3,count) = sqrt(tau_p * P_pt) * sum(H_ch(1:3,count));
%    H_ch(1:3,count) = H_ch(1:3,count) + noise;
%    H_ch(1:3,count) =  H_ch(1:3,count) .* PL(1:3,count);
%    H_ch(1:3,count) = MMSE_const_ch * H_ch(1:3,count);
   
end

Eta_sqroot = sqrt(Eta);
Eta_OMA_sqroot = sqrt(Eta_OMA);

%% Use the H_MMSE to get the precoding weights and thus precoding matrix
%Precode_mx = zeros(N_ue , M_ap); % Create an empty precoding matrix

% norm_ch = sqrt(H_MMSE .* conj(H_MMSE));



end