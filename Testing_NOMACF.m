%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implementing the NOMA Cell-Free Massive MIMO system by plotting
%        the achievable rate against the number of users
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = Testing_NOMACF()

PL = CellFreeSystem (100 , 4);


R_NOMA = zeros(1,80);
R_OMA = zeros(1,80);

for N_ue = 5:5:400
     i = N_ue/5;
     [Eta , Eta_sqroot , Eta_OMA , Eta_OMA_sqroot] = Precoding_ConjugateBF(100, N_ue, PL);
     [R_NOMA(1,i) , R_OMA(1,i)] = NOMASignal_Downlink(N_ue , PL , Eta , Eta_sqroot, Eta_OMA , Eta_OMA_sqroot);
%      if R_OMA(1,i) < 0
%          if R_NOMA(1,i) < 0
%              R_OMA(1,i) = 0;
%              R_NOMA(1,i) = 0;
%          else
%              R_OMA(1,i) = 0;
%          end
%      end
end

figure

N_ue = 5:5:400;
plot(N_ue , R_NOMA ,'^-', N_ue , R_OMA , 'o-');
ylim([0 inf]);
legend('NOMA Rate-Imperfect SIC (p = 0.1)' , 'OMA (Orthogonal Multiple Access)');
xlabel('Number of users');
ylabel('Acheivable rate in (bit/second/Hz)');


end