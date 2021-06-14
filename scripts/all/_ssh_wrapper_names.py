#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# DEP: python3

import itertools
import sys

SSH_WRAPPER_FEATURES = ['jump', 'unsafe']


def wrapper_feat_gen(features):
    for feat in features:
        yield feat

    for feat_count in range(2, len(features) + 1):
        for feat_selection in itertools.combinations(features, feat_count):
            yield "-".join(feat_selection)
# ---


def wrapper_name_gen(features):
    for cmd_variant in ['ssh', 'scp', 'sftp']:
        for feat_variant in wrapper_feat_gen(features):
            yield f"{cmd_variant}-{feat_variant}"
# ---


def main():
    for name in wrapper_name_gen(SSH_WRAPPER_FEATURES):
        sys.stdout.write(name + "\n")


if __name__ == '__main__':
    main()
