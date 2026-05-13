eem = []
eem(1,1:size(eem_init,2)) = eem_init(1,1:size(eem_init,2));
eem(1:size(eem_init,1),1) = eem_init(1:size(eem_init,1),1);
eem(2:size(eem_init,1),2:size(eem_init,2)) = eem_init(2:size(eem_init,1),2:size(eem_init,2)) - moyenneH2OMQ(2:size(moyenneH2OMQ,1),2:size(moyenneH2OMQ,2));

h_s = eemplot('newfig',eem)
h_s = eemplot('newfig',eem_init)