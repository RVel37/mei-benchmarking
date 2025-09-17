version 1.0

import "tasks/pairBamIdxs.wdl" as pairBamIdxs
import "tasks/scramble.wdl" as scramble
import "tasks/melt.wdl" as melt
import "tasks/deepMei.wdl" as deepMei

workflow main {
    input {
        Array[File] bams
        Array[File] bais
        File refGenomeBwaTar
        String dockerSamtools
        String dockerScramble
        String dockerMelt
        String dockerDeepMei
    }

    scatter (input_bam in bams) {
        call pairBamIdxs.pairBamIdxs as pb {
            input:
            bam=input_bam,
            bais=bais,
            dockerSamtools=dockerSamtools
        }

        call scramble.scramble {
            input:
            bam=pb.paired_bam, 
            bai=pb.bai,
            refGenomeBwaTar=refGenomeBwaTar,
            dockerScramble=dockerScramble
        }

        call melt.melt {
            input:
            bam=pb.paired_bam, 
            bai=pb.bai,
            refGenomeBwaTar=refGenomeBwaTar,
            dockerMelt=dockerMelt
        }

        # call deepMei.deepMei {
        #     input:
        #     bam=pb.paired_bam, 
        #     bai=pb.bai,
        #     refGenomeBwaTar=refGenomeBwaTar,
        #     dockerDeepMei=dockerDeepMei
        # }

    }

output {
    Array[File?] scramble_vcfs = scramble.vcf
    Array[File?] scramble_clusters = scramble.clusters
    Array[File?] melt_vcfs = melt.vcf
    Array[File?] melt_logs = melt.log
    # Array[File?] deepmei_vcfs = deepMei.deepMei.vcf
}
}