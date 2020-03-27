#!/homes/kmaibach/miniconda3/bin/python

import unittest
import os
import subprocess
import tempfile
from collections import OrderedDict
# import shutil


class Test(unittest.TestCase):

    def setUp(self):
        self.fp_workdir = tempfile.mkdtemp()

        sequences = {
            "CCCAA+AAAUGGG": "9",
            "CCCCCCA+AUCCCCCAAAGGGGGGGGGGGG": "22979",
            "CCC+GGG": "6",
            "UCC+GGG": "6",
            "CCU+GGG": "6",
            "CCC+ACCCAAAGGGGGG": "66",
            "CCU+ACCCAAAGGGGGG": "68",
            "CCC+AUCCAAAGGGGGG": "66",
            "CCC+ACCCCCCAAAGGGGGGGGG": "1196",
            "CCC+AUCCCCCAAAGGGGGGGGG": "1196",
            "CCCCCCCCCAAAGGGGGGA+GGG": "1196",
            "CCCUCCCCCAAAGGGGGGA+GGG": "1378",
            "CCCAACCCCCCAAAGGGGGGA+GGG": "816",
            "CCCAAUCCCCCAAAGGGGGGA+GGG": "990",
            "CCCCAACCCCAA+AGGGGAAGGGGA": "307",
            "CCACCAAAGGACCAAAGGA+GG": "19",
            "GCAUCUGCGUAUCUCGGAUAAUGCAAC+UUGAUAACUAUGC": "29096",
            "CAAUUUAAUCCCCACCGGUCACU+AAAGCCAUUAGG": "1404",
            # use only for test 2
            "GCAUCUGCGUAUCUCGGAUAAUGCAAC+UUGAUAACUAUGCUAUGG": "177456",
            "GGUUUGGGUCUUAAAGGGGCUCUGGGAUACUCCCA+CGGACC": "479122",
            "GGUUUAUCGGGUCUUAAAGGGGCUCUGGGAUACUCCCA+CGGACC": "1026645",
            "GGUUUAUCGGGUCUUAAAGGGGCUCUGGGAUACAUAUUCCCA+CGGACC": "2242901",
            "GGUUUAUCGGGUGCUUAAAGGGGGCUCUGGGAUACAUAUUCCCA+CGGACC": "4219244",
            "GGUUUAUUAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUUGGGAUACAUAUUCCCA+CGGACC": "660278945",
            # "GGACAGACUACAUAGCGAUAUUCGCGAGGGACGGUCCAAGCCAUAAAGAAGACAUUAUGCCAACG+AUCGGUAGAGGCGCUUGCUGAGAUAUCUUUGGUCUUCUAGCGCCUAAGGGCUUCCACACUCCUUGCAUCGUAAAAAUCUAAGAA": "12412333775906063261",
            "UAGGAAGAUCGAGUGGCGGCUUCAACCAGGUCGACCCUGUAAAGGGAAGCUUAAAAUCAAGGACCUACCG+UAAUCGUAACUACGCACUAAGCGAAUACGUGGCGAGCCGGA": "8615975181702",
            "GGCCACCCUUGACCGUUUUCCCGCUAGCCAACUUACGUGGUGGGAGGACGGUCAACUAUGUGGACAACUAUAUAGUGGAGCGUAGCGACGGUCUGUUGGUACCAGUGU+CCAACAGGCUGUCCGCUCCUGGCC": "7930496389100622030",
            "GGCCAUGACCGUUUUCCCGCUAGCCAACUUACGUGGUGGGAGGACGGUCAACUAUGUGGACAACUAUAUAGUGGAGCGGACGGUCUGUUGGUACCAGUGU+CCAACAGGCUGUCCGCUCCUGGCC": "560970781638806571",
            # "UGCUUUGGUCUCUUAGGUUACAGACCAGAUAACGUGCUCUCUUCUCAAGGUGUCAUGGAAAAACGCUUACUAAGAUGAGGAGCGUUGCAUCUGCGUAUCUCGGAUAAUGCAAC+UUGAUAACUAUGCUAUGG": "3087043724457592213",
            "GGUUUAUUAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUAGCACGCUGGGAUACAUAUUCCCAAUUGUU+CGGACC": "49821805198",
            "GGUUUAUUACGAAAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUGACGAGCACGCUGGGAUACAUAUUCCCAAUUGUU+CGGACC": "766440248432",
            "GGUUUAUUACGAAAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUGACGCCACGCUCAUGGAGCACGCUGGGAUACAUAUUCCCAAUUGUUAGGGCCUGGAAGAC+CGGACC": "3211827845108803",
            # "UGGUCUCGGUUUAUUACGAAAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUGACGCCACGCUCAUGGAGCACGCUGGGAUACAUAUUCCCAAUUGUUAGGGCCUGGAAGAC+CGGACCGACCAAGCAU": "709508811230949176",
            "GUAGUUGACAGCCCUGAAAUUCGGUCG+CUUUUAAUUAACUCCUUCCUCUUCGGACCGAUGUGCCCUUGGAUAUCCUAUAUGGAAUUUGGUGUCAGGAUUGUGCCAAGGCCACGAACACAGGAAUGCCAUACAA": "462656285088435985",
            ## "CCACGGAGUUGUACAUCUCCUGUGCGAUGCCCCGCAUCCUGAAUAGGGCAGGUUGCCAGUGGAGGGUUGGGGAUACUUCCGAA+UCCAUAUCCACUCGUGACCGGAGGUUAGUACUUUACGAGCGAAAGGGUGCCCGCGCUUCUUUUCCGGACCCCGCACCACGCAUGUAGAGUACUUGGGAACGAAAGGCCGUAACACGGUGGGACAAAAGCAGCUGCCUAUACGCCGGUUUACCAAGGUCCCCUGGUUGAAUAUCAUGUCUGUGUUGAA": 223925561507966359,
            ## "GGCACACCCUUGACCGUUUCCUCGUUCCGCUAGCCAACUUACGUGGUGGCAGAUUGGACGGUCAACUAUAUGUGGACAACUAUAAAUUAGUGGAGCGUAGCGACGGAUCUGUAUUGGUACCAGUGU+CCAAACCAGGCUGUCUCGACUCCUGGCC": 1817937833786320951,
            ## "GGCCACCCUUGACCGUUUCCUCGUUCCGCUAGCCAACUUACGUGGUGGCAGAUUGGACGGUCAACUAUAUGUGGACAACUAUAAAUUAGUGGAGCGUAGCGACGGAUCUGUAUUGGUACCAGUGU+CCAAACCAGGCUGUCUCGACUCCUGGCC": 15606250151430488623,
            ## "GGCCACCCUUGACCGUUUCCUCGUUCCGCUAGCCAACUUACGUGGUGGCAGAUUGGACGGUCAACUAUAUGUGGACAACUAUAAAUUAGUGGAGCGUAGCGACGGUCUGUUGGUACCAGUGU+CCAACAGGCUGUCCGCUCCUGGCC": 17872895797936292537,
            ## "UAGGAAGAUCGAGUGGCGGCUUCAACCAGGUCGACCCUGUAAAGGGAAGCUUAAAAUCAAGGACCUACCG+UAUGCGACGGUCGCAUGACUUGGCGCUGAGCCAGUCCGCACUUUCGUAAUCGUAACUACGCACUAAGCGAAUACGUGGCGAGCCGGA": 2623438644795693868,
            ## "GAAUACAGACAGAGUUAUGAAGGACGCUACGCAUUGUUAAAACGUCGUCUCGUUCAUUGGUCUCGGUUUAUUACGAAAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUGACGCCACGCUCAUGGAGCACGCUGGGAUACAUAUUCCCAAUUGUUAGGGCCUGGAAGAC+CGGACCGACCAAGCAU": 15187308047988240186
        }

        self.sequences = OrderedDict(sequences.items())

    def tearDown(self):
        pass
        # shutil.rmtree(self.fp_workdir)  # remove temporary directory

    def testUnambiguousness(self):
        os.system('basedir=`pwd` && cd "%s" && gapc -p "alg_dotBracket_unique*alg_count" $basedir/../../../cofold_nodangle.gap -I $basedir/../../../' % self.fp_workdir)
        os.system('basedir=`pwd` && cd "%s" && make -f out.mf CPPFLAGS_EXTRA="-I $basedir/../../../"' % self.fp_workdir)
        for seq in list(self.sequences.keys())[0:19]:
            cmd = ('%s/out "%s"' % (self.fp_workdir, seq))
            dot_count = [(subprocess.check_output(cmd, shell=True)).decode("utf-8")]
            for element in dot_count:
                dot_count_list = element.split('\n')
                for el in dot_count_list:
                    if not (el == 'Answer: ' or el == ''):
                        self.assertEqual(el.split(",")[1], ' 1 )')

    def testCount(self):
        os.system('basedir=`pwd` && cd "%s" && gapc -p "alg_count" $basedir/../../../cofold_nodangle.gap -I $basedir/../../../' % self.fp_workdir)
        os.system('basedir=`pwd` && cd "%s" && make -f out.mf CPPFLAGS_EXTRA="-I $basedir/../../../"' % self.fp_workdir)
        for seq, count in self.sequences.items():
            cmd = ('%s/out "%s"' % (self.fp_workdir, seq))
            candidates = (subprocess.check_output(cmd, shell=True)).decode("utf-8")
            self.assertEqual(count, candidates.split('\n')[1])


if __name__ == "__main__":
    unittest.main()
