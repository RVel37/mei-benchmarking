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

        call scramble.scramble {
            input:
            bam=bam, 
            bai=pairBamIdxs.bai,
            refGenomeBwaTar=refGenomeBwaTar,
            dockerScramble=dockerScramble
        }

        call melt.melt {
            input:
            bam=bam, 
            bai=pairBamIdxs.bai,
            refGenomeBwaTar=refGenomeBwaTar,
            dockerMelt=dockerMelt
        }

        call deepMei.deepMei {
            input:
            bam=bam, 
            bai=pairBamIdxs.bai,
            refGenomeBwaTar=refGenomeBwaTar,
            dockerDeepMei=dockerDeepMei
        }
    }
    output {
    Array[File]? scramble_vcfs=scramble.vcf
    Array[File]? scramble_clusters=scramble.clusters
    Array[File]? melt_vcfs= melt.vcf
    Array[File]? melt_logs= melt.log
    Array[File]? deepmei_vcfs= deepMei.vcf
    }
}