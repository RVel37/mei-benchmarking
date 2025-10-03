version 1.0

import "tasks/pairBamIdxs.wdl" as pairBamIdxs
import "tasks/deepMei.wdl" as deepMei

workflow main {
    input {
        Array[File] bams
        Array[File] bais
        File refGenomeBwaTar
        String dockerSamtools
        String dockerDeepMei
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
