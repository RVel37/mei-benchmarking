version 1.0

import "tasks/pairBamIdxs.wdl" as pairBamIdxs
import "tasks/scramble.wdl" as scramble
import "tasks/melt.wdl" as melt
import "tasks/deepmei.wdl" as deepMei

workflow meiAnalysis {
    input {
        Array[File] bams
        Array[File] bais
        String dockerScramble
        String dockerMelt
        String dockerDeepMei
        File refGenomeBwaTar
    }

    SCATTER (bam in bams){
        task pairBamIdxs {
            input:
            bam=bam,
            bais=bais
        }

        
    }
}