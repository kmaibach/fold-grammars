//computes csrKHs with Strategy C
  help_pkiss_C   = 
    .[
      int i = t_0_i;
      int j = t_0_j;

      for (int h = i+minLengthKissingHairpinStems()+1; h<=j-3*minLengthKissingHairpinStems()-2*2-3; h=h+1) {
        for (int m = h+2*minLengthKissingHairpinStems()+2*2+2; m<=j-minLengthKissingHairpinStems()-1; m=m+1) {
          rpk_setup(m-2-minLengthKissingHairpinStems());
          for (int k = m-minLengthKissingHairpinStems()-2-2; k>=h+minLengthKissingHairpinStems()+2; k=k-1) {
            int betamaxlen = second(stacklen(t_0_seq, h, m));
            if (betamaxlen < 2) {
              continue;
            }
            if (i+minLengthKissingHairpinStems()+1>h || h+minLengthKissingHairpinStems()+2>k || m+minLengthKissingHairpinStems()+1>j) {
              continue;
            }

            mfeanswer optPK = get_pk(h,j,k+2,m);
            if ((!is_empty(optPK)) && (optPK.energy < rpk_energy(k+1))) {
              rpk_set(k, optPK.energy, optPK.betaLeftOuter);
            } else {
              rpk_set(k);
            }
            int l = rpk_index(k);

			int alphamaxlen = second(stacklen(t_0_seq, i, k));
            if (alphamaxlen < minLengthKissingHairpinStems()) {
              continue;
            }
            int alphareallen = min(alphamaxlen, h-i-1);
            if (alphareallen < minLengthKissingHairpinStems()) {
              continue;
            }
            
            if (k+2>l || l+2+minLengthKissingHairpinStems()>m) {
              continue;
            }
            int gammamaxlen = second(stacklen(t_0_seq, l, j));
            if (gammamaxlen < minLengthKissingHairpinStems()) {
              continue;
            }
            int gammareallen = min(gammamaxlen, j-m-1);
            if (gammareallen < minLengthKissingHairpinStems()) {
              continue;
            }
            int betareallen = min(min(betamaxlen, k-h-alphareallen), min(betamaxlen, m-l-gammareallen));
            if (betareallen < 2) {
              continue;
            }
            int stackenergies =   first(stacklen(t_0_seq, i,                k               ))  // maximal alpha helix
                                + first(stacklen(t_0_seq, h,                m               ))  // maximal beta helix
                                + first(stacklen(t_0_seq, l,                j               ))  // maximal gamma helix
                                - first(stacklen(t_0_seq, i+alphareallen-1, k-alphareallen+1))  // reduced part of alpha helix
                                - first(stacklen(t_0_seq, h+betareallen -1, m-betareallen +1))  // reduced part of beta helix
                                - first(stacklen(t_0_seq, l+gammareallen-1, j-gammareallen+1)); // reduced part of gamma helix
            INNER(CODE);
          }
        }
      }
     ].
    {
      pkiss(REGION, REGION, REGION, REGION, REGION) .{
        pkiss(REGION[i, i+alphareallen],                                                        //alpha open
          front[i+alphareallen+1, h] .(m).,                                                     //front
          REGION[h, h+betareallen],                                                             //beta open
          middle[h+betareallen, k-alphareallen] .(m-betareallen, i+alphareallen).,              //middle 1
          REGION[k-alphareallen, k],                                                            //alpha close
          middleNoDangling[k+1, l-1],                                                           //middle 2
          REGION[l, l+gammareallen],                                                            //gamma open
          middleNoCoaxStack[l+gammareallen, m-betareallen] .(j-gammareallen, h+betareallen).,   //middle 3
          REGION[m-betareallen, m],                                                             //beta close
          back[m, j-gammareallen-1] .(h).,                                                      //back
          REGION[j-gammareallen, j];                                                            //gamma close
          stackenergies) 
        }.
    } # hKnot;