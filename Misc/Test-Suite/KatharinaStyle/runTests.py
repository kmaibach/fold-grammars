#!/usr/bin/python

import unittest
import os
import subprocess
import tempfile
# import shutil


class Test(unittest.TestCase):

    def setUp(self):
        self.fp_workdir = tempfile.mkdtemp()
        os.system('basedir=`pwd` && cd "%s" && gapc -p "alg_dotBracket*alg_count" $basedir/../../../nodangle.gap -I $basedir/../../../' % self.fp_workdir)
        os.system('basedir=`pwd` && cd "%s" && make -f out.mf CPPFLAGS_EXTRA="-I $basedir/../../../"' % self.fp_workdir)

        self.sequences = [
            "CCCAa+aaaUGGG",
            "CCCCCCa+auCCCCCaaaGGGGGGGGGGGG",
            "CCC+GGG",
            "UCC+GGG",
            "CCu+GGG",
            "CCC+aCCCaaaGGGGGG",
            "CCU+aCCCaaaGGGGGG",
            "CCC+aUCCaaaGGGGGG",
            "CCC+aCCCCCCaaaGGGGGGGGG",
            "CCC+aUCCCCCaaaGGGGGGGGG",
            "CCC+aUCCCCCaaaGGGGGGGGG",
            "CCC+aUCCCCCaaaGGGGGGGGG",
            "CCCCCCCCCaaaGGGGGGa+GGG",
            "CCCuCCCCCaaaGGGGGGa+GGG",
            "CCCuCCCCCaaaGGGGGGa+GGG",
            "CCCaaCCCCCCaaaGGGGGGa+GGG",
            "CCCaaUCCCCCaaaGGGGGGa+GGG",
            "CCCaaUCCCCCaaaGGGGGGa+GGG",
            "CCCCaaCCCCaa+aGGGGaaGGGGa",
            "CCACCAAAGGACCAAAGGA+GG",
            "GCAUCUGCGUAUCUCGGAUAAUGCAAC+UUGAUAACUAUGCUAUGG",
            "GCAUCUGCGUAUCUCGGAUAAUGCAAC+UUGAUAACUAUGC",
            "CAAUUUAAUCCCCACCGGUCACU+AAAGCCAUUAGG",
            "GGUUUGGGUCUUAAAGGGGCUCUGGGAUACUCCCA+CGGACC",
            "GGUUUAUCGGGUCUUAAAGGGGCUCUGGGAUACUCCCA+CGGACC",
            "GGUUUAUCGGGUCUUAAAGGGGCUCUGGGAUACAUAUUCCCA+CGGACC",
            "GGUUUAUCGGGUGCUUAAAGGGGGCUCUGGGAUACAUAUUCCCA+CGGACC"
            # sequences too long for homes-usage - use on cluster!
            # "GGUUUAUUAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUUGGGAUACAUAUUCCCA+CGGACC",
            # "GGACAGACUACAUAGCGAUAUUCGCGAGGGACGGUCCAAGCCAUAAAGAAGACAUUAUGCCAACG+AUCGGUAGAGGCGCUUGCUGAGAUAUCUUUGGUCUUCUAGCGCCUAAGGGCUUCCACACUCCUUGCAUCGUAAAAAUCUAAGAA",
            # "CCACGGAGUUGUACAUCUCCUGUGCGAUGCCCCGCAUCCUGAAUAGGGCAGGUUGCCAGUGGAGGGUUGGGGAUACUUCCGAA+UCCAUAUCCACUCGUGACCGGAGGUUAGUACUUUACGAGCGAAAGGGUGCCCGCGCUUCUUUUCCGGACCCCGCACCACGCAUGUAGAGUACUUGGGAACGAAAGGCCGUAACACGGUGGGACAAAAGCAGCUGCCUAUACGCCGGUUUACCAAGGUCCCCUGGUUGAAUAUCAUGUCUGUGUUGAA",
            # "UAGGAAGAUCGAGUGGCGGCUUCAACCAGGUCGACCCUGUAAAGGGAAGCUUAAAAUCAAGGACCUACCG+UAAUCGUAACUACGCACUAAGCGAAUACGUGGCGAGCCGGA",
            # "GGCACACCCUUGACCGUUUCCUCGUUCCGCUAGCCAACUUACGUGGUGGCAGAUUGGACGGUCAACUAUAUGUGGACAACUAUAAAUUAGUGGAGCGUAGCGACGGAUCUGUAUUGGUACCAGUGU+CCAAACCAGGCUGUCUCGACUCCUGGCC",
            # "GGCCACCCUUGACCGUUUCCUCGUUCCGCUAGCCAACUUACGUGGUGGCAGAUUGGACGGUCAACUAUAUGUGGACAACUAUAAAUUAGUGGAGCGUAGCGACGGAUCUGUAUUGGUACCAGUGU+CCAAACCAGGCUGUCUCGACUCCUGGCC",
            # "GGCCACCCUUGACCGUUUCCUCGUUCCGCUAGCCAACUUACGUGGUGGCAGAUUGGACGGUCAACUAUAUGUGGACAACUAUAAAUUAGUGGAGCGUAGCGACGGUCUGUUGGUACCAGUGU+CCAACAGGCUGUCCGCUCCUGGCC",
            # "GGCCACCCUUGACCGUUUUCCCGCUAGCCAACUUACGUGGUGGGAGGACGGUCAACUAUGUGGACAACUAUAUAGUGGAGCGUAGCGACGGUCUGUUGGUACCAGUGU+CCAACAGGCUGUCCGCUCCUGGCC",
            # "GGCCAUGACCGUUUUCCCGCUAGCCAACUUACGUGGUGGGAGGACGGUCAACUAUGUGGACAACUAUAUAGUGGAGCGGACGGUCUGUUGGUACCAGUGU+CCAACAGGCUGUCCGCUCCUGGCC",
            # "UAGGAAGAUCGAGUGGCGGCUUCAACCAGGUCGACCCUGUAAAGGGAAGCUUAAAAUCAAGGACCUACCG+UAAUCGUAACUACGCACUAAGCGAAUACGUGGCGAGCCGGA",
            # "UAGGAAGAUCGAGUGGCGGCUUCAACCAGGUCGACCCUGUAAAGGGAAGCUUAAAAUCAAGGACCUACCG+UAUGCGACGGUCGCAUGACUUGGCGCUGAGCCAGUCCGCACUUUCGUAAUCGUAACUACGCACUAAGCGAAUACGUGGCGAGCCGGA",
            # "GAAUACAGACAGAGUUAUGAAGGACGCUACGCAUUGUUAAAACGUCGUCUCGUUCAUUGGUCUCGGUUUAUUACGAAAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUGACGCCACGCUCAUGGAGCACGCUGGGAUACAUAUUCCCAAUUGUUAGGGCCUGGAAGAC+CGGACCGACCAAGCAU",
            # "UGCUUUGGUCUCUUAGGUUACAGACCAGAUAACGUGCUCUCUUCUCAAGGUGUCAUGGAAAAACGCUUACUAAGAUGAGGAGCGUUGCAUCUGCGUAUCUCGGAUAAUGCAAC+UUGAUAACUAUGCUAUGG",
            # "GGUUUAUUAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUAGCACGCUGGGAUACAUAUUCCCAAUUGUU+CGGACC",
            # "GGUUUAUUACGAAAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUGACGAGCACGCUGGGAUACAUAUUCCCAAUUGUU+CGGACC",
            # "GGUUUAUUACGAAAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUGACGCCACGCUCAUGGAGCACGCUGGGAUACAUAUUCCCAAUUGUUAGGGCCUGGAAGAC+CGGACC",
            # "UGGUCUCGGUUUAUUACGAAAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUGACGCCACGCUCAUGGAGCACGCUGGGAUACAUAUUCCCAAUUGUUAGGGCCUGGAAGAC+CGGACCGACCAAGCAU",
            # "GUAGUUGACAGCCCUGAAAUUCGGUCG+CUUUUAAUUAACUCCUUCCUCUUCGGACCGAUGUGCCCUUGGAUAUCCUAUAUGGAAUUUGGUGUCAGGAUUGUGCCAAGGCCACGAACACAGGAAUGCCAUACAA"
        ]

    def tearDown(self):
        pass
        # shutil.rmtree(self.fp_workdir)  # remove temporary directory

    def testUnambiguousness(self):
        for seq in self.sequences:
            cmd = ('%s/out "%s"' % (self.fp_workdir, seq))
            dot_count = [(subprocess.check_output(cmd, shell=True)).decode("utf-8")]
            for element in dot_count:
                dot_count_list = element.split('\n')
                for el in dot_count_list:
                    if not (el == 'Answer: ' or el == ''):
                        self.assertEqual(el.split(",")[1], ' 1 )')


class Test2(unittest.TestCase):

    def setUp(self):
        self.fp_workdir = tempfile.mkdtemp()
        os.system('basedir=`pwd` && cd "%s" && gapc -p "alg_count" $basedir/../../../nodangle.gap -I $basedir/../../../' % self.fp_workdir)
        os.system('basedir=`pwd` && cd "%s" && make -f out.mf CPPFLAGS_EXTRA="-I $basedir/../../../"' % self.fp_workdir)

        self.count = {
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
            "GCAUCUGCGUAUCUCGGAUAAUGCAAC+UUGAUAACUAUGCUAUGG": "177456",
            "GCAUCUGCGUAUCUCGGAUAAUGCAAC+UUGAUAACUAUGC": "29096",
            "CAAUUUAAUCCCCACCGGUCACU+AAAGCCAUUAGG": "1404",
            "GGUUUGGGUCUUAAAGGGGCUCUGGGAUACUCCCA+CGGACC": "479122",
            "GGUUUAUCGGGUCUUAAAGGGGCUCUGGGAUACUCCCA+CGGACC": "1026645",
            "GGUUUAUCGGGUCUUAAAGGGGCUCUGGGAUACAUAUUCCCA+CGGACC": "2242901",
            "GGUUUAUCGGGUGCUUAAAGGGGGCUCUGGGAUACAUAUUCCCA+CGGACC": "4219244",
            "GGUUUAUUAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUUGGGAUACAUAUUCCCA+CGGACC": "660278945",

            ## not working "GGACAGACUACAUAGCGAUAUUCGCGAGGGACGGUCCAAGCCAUAAAGAAGACAUUAUGCCAACG+AUCGGUAGAGGCGCUUGCUGAGAUAUCUUUGGUCUUCUAGCGCCUAAGGGCUUCCACACUCCUUGCAUCGUAAAAAUCUAAGAA": "12412345278531832733",
            ## vs. 12412333775906063261

            ## "CCACGGAGUUGUACAUCUCCUGUGCGAUGCCCCGCAUCCUGAAUAGGGCAGGUUGCCAGUGGAGGGUUGGGGAUACUUCCGAA+UCCAUAUCCACUCGUGACCGGAGGUUAGUACUUUACGAGCGAAAGGGUGCCCGCGCUUCUUUUCCGGACCCCGCACCACGCAUGUAGAGUACUUGGGAACGAAAGGCCGUAACACGGUGGGACAAAAGCAGCUGCCUAUACGCCGGUUUACCAAGGUCCCCUGGUUGAAUAUCAUGUCUGUGUUGAA": 223925561507966359,

            ## not working "UAGGAAGAUCGAGUGGCGGCUUCAACCAGGUCGACCCUGUAAAGGGAAGCUUAAAAUCAAGGACCUACCG+UAAUCGUAACUACGCACUAAGCGAAUACGUGGCGAGCCGGA": "8615977135691",
            ## vs. 8615975181702

            ## "GGCACACCCUUGACCGUUUCCUCGUUCCGCUAGCCAACUUACGUGGUGGCAGAUUGGACGGUCAACUAUAUGUGGACAACUAUAAAUUAGUGGAGCGUAGCGACGGAUCUGUAUUGGUACCAGUGU+CCAAACCAGGCUGUCUCGACUCCUGGCC": 1817937833786320951,
            ## "GGCCACCCUUGACCGUUUCCUCGUUCCGCUAGCCAACUUACGUGGUGGCAGAUUGGACGGUCAACUAUAUGUGGACAACUAUAAAUUAGUGGAGCGUAGCGACGGAUCUGUAUUGGUACCAGUGU+CCAAACCAGGCUGUCUCGACUCCUGGCC": 15606250151430488623,
            ## "GGCCACCCUUGACCGUUUCCUCGUUCCGCUAGCCAACUUACGUGGUGGCAGAUUGGACGGUCAACUAUAUGUGGACAACUAUAAAUUAGUGGAGCGUAGCGACGGUCUGUUGGUACCAGUGU+CCAACAGGCUGUCCGCUCCUGGCC": 17872895797936292537,

            "GGCCACCCUUGACCGUUUUCCCGCUAGCCAACUUACGUGGUGGGAGGACGGUCAACUAUGUGGACAACUAUAUAGUGGAGCGUAGCGACGGUCUGUUGGUACCAGUGU+CCAACAGGCUGUCCGCUCCUGGCC": "7930496389100622030",
            "GGCCAUGACCGUUUUCCCGCUAGCCAACUUACGUGGUGGGAGGACGGUCAACUAUGUGGACAACUAUAUAGUGGAGCGGACGGUCUGUUGGUACCAGUGU+CCAACAGGCUGUCCGCUCCUGGCC": "560970781638806571",

            ## "UAGGAAGAUCGAGUGGCGGCUUCAACCAGGUCGACCCUGUAAAGGGAAGCUUAAAAUCAAGGACCUACCG+UAUGCGACGGUCGCAUGACUUGGCGCUGAGCCAGUCCGCACUUUCGUAAUCGUAACUACGCACUAAGCGAAUACGUGGCGAGCCGGA": 2623438644795693868,
            ## "GAAUACAGACAGAGUUAUGAAGGACGCUACGCAUUGUUAAAACGUCGUCUCGUUCAUUGGUCUCGGUUUAUUACGAAAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUGACGCCACGCUCAUGGAGCACGCUGGGAUACAUAUUCCCAAUUGUUAGGGCCUGGAAGAC+CGGACCGACCAAGCAU"; 15187308047988240186,

            "UGCUUUGGUCUCUUAGGUUACAGACCAGAUAACGUGCUCUCUUCUCAAGGUGUCAUGGAAAAACGCUUACUAAGAUGAGGAGCGUUGCAUCUGCGUAUCUCGGAUAAUGCAAC+UUGAUAACUAUGCUAUGG": "3087043724457592213",
            "GGUUUAUUAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUAGCACGCUGGGAUACAUAUUCCCAAUUGUU+CGGACC": "49821805198",
            "GGUUUAUUACGAAAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUGACGAGCACGCUGGGAUACAUAUUCCCAAUUGUU+CGGACC": "766440248432",
            "GGUUUAUUACGAAAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUGACGCCACGCUCAUGGAGCACGCUGGGAUACAUAUUCCCAAUUGUUAGGGCCUGGAAGAC+CGGACC": "3211827845108803",
            "UGGUCUCGGUUUAUUACGAAAGGAUGUCGGGUGCUUAAAGGGGGCUCACGUCUGACGCCACGCUCAUGGAGCACGCUGGGAUACAUAUUCCCAAUUGUUAGGGCCUGGAAGAC+CGGACCGACCAAGCAU": "709508811230949176",

            ## not working "GUAGUUGACAGCCCUGAAAUUCGGUCG+CUUUUAAUUAACUCCUUCCUCUUCGGACCGAUGUGCCCUUGGAUAUCCUAUAUGGAAUUUGGUGUCAGGAUUGUGCCAAGGCCACGAACACAGGAAUGCCAUACAA": "462657635383350133"
            ## vs. 462656285088435985
        }

    def tearDown(self):
        pass
        # shutil.rmtree(self.fp_workdir)  # remove temporary directory

    def testCount(self):
        for seq, count in self.count.items():
            cmd = ('%s/out "%s"' % (self.fp_workdir, seq))
            candidates = (subprocess.check_output(cmd, shell=True)).decode("utf-8")
            self.assertEqual(count, candidates.split('\n')[1])


if __name__ == "__main__":
    unittest.main()