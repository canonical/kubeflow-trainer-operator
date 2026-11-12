# Trainer

## Overview

This repository hosts the Kubernetes Trainer for Kubeflow training jobs.

## Description

The [Kubeflow Trainer][1] provides Kubernetes custom resources to run distributed or
non-distributed training jobs, such as TFJobs and PytorchJobs. The Training Operator in this
repository is a Python script which wraps the latest released Kubeflow Training Operator
[manifests][2], providing lifecycle management and handling events (install, upgrade, integrate,
remove). It is one of the [Charmed Kubeflow][3] operators.

## Usage

While it is possible to deploy the Training Operator as a standalone operator, it works best when
deployed alongside other components included in the Kubeflow bundle. For installation steps, please
refer to the [installation][4] guide.

[1]: https://www.kubeflow.org/docs/components/trainer/
[2]: https://github.com/kubeflow/manifests/tree/master/applications/trainer
[3]: https://github.com/canonical/bundle-kubeflow
[4]: https://charmed-kubeflow.io/docs/install


### GPU support

To run `TrainJob` with the `torch-distributed` runtime on NVIDIA GPUs, the cluster needs the
`nvidia` `RuntimeClass` (for example, from the NVIDIA GPU Operator). The charm does not set it by
default, so that the runtime also works on clusters without GPUs. Enable it by patching the
`ClusterTrainingRuntime`:

```bash
kubectl patch clustertrainingruntime torch-distributed --type=json -p='[
  {"op":"add","path":"/spec/template/spec/replicatedJobs/0/template/spec/template/spec/runtimeClassName","value":"nvidia"}
]'
```

Then request GPUs when submitting the job with the Kubeflow SDK:

```python
job_name = client.train(
    trainer=CustomTrainer(
        func=train_fashion_mnist_gpu,
        # Number of PyTorch nodes for distributed training.
        num_nodes=1,
        # Resources for each PyTorch node.
        resources_per_node={
            "cpu": 3,
            "memory": "8Gi",
            "nvidia.com/gpu": 1,
        },
    ),
)
```