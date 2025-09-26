version 1.0

import "tasks/pairBamIdxs.wdl" as pairBamIdxs
import "tasks/scramble.wdl" as scramble
import "tasks/melt.wdl" as melt
import "tasks/deepMei.wdl" as deepMei
import "tasks/mobster.wdl" as mobster

workflow main {
    input {
        Array[File] bams
        Array[File] bais
        File refGenomeBwaTar
        String dockerSamtools
        String dockerScramble
        String dockerMelt
        String dockerDeepMei
        String dockerMobster
        String dockerMobVcf
    }

    scatter (input_bam in bams) {
        call pairBamIdxs.pairBamIdxs as pb {
            input:
            bam=input_bam,
            bais=bais,
            dockerSamtools=dockerSamtools
        }


        call deepMei.deepMei {
            input:
            bam=pb.paired_bam, 
            bai=pb.bai,
            refGenomeBwaTar=refGenomeBwaTar,
            dockerDeepMei=dockerDeepMei
        }

    }

    output {
        Array[File?] deepmei_vcfs = deepMei.vcf
    }
}