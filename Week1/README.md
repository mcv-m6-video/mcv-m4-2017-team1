
- Our scripts assume the following paths (relative to the root of the project):

  - Datasets:

    - datasets/highway/reducedGT (200 frames of ground truth)
    - datasets/highway/reducedinput (200 input frames) 
    - dataset/LKflow/training/flow_noc

  - Results provided:

    - results/highway/testA
    - results/highway/testB
    - results/LKflow

  - Tasks:

    - Task1 provides the F1, Precision and Recall for the two methods A & B.
    - Task2 shows either the evolution of the TP and total foreground pixels or the evolution of the F Measure (which is saved in a video) along the sequence A or B.
    - Task 3 provides the MSEN and PEPN of the sequences 45 and 157 of LKflow.
    - Task 4 shows the evolution of the F Measure along a sequence, for different numbers of de-synchronized frames and the evolution of the total F Measure of the sequence with respect to the number of de-syncrhonized frames.
    - Task 5 shows a representation of the optical flow results
