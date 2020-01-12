from __future__ import absolute_import, division, print_function

__metaclass__ = type

from ansible_collections.launchdarkly_labs.collection.plugins.module_utils.clause import (
    clause_argument_spec,
)


def rule_argument_spec():
    return dict(
        type="list",
        apply_defaults=True,
        options=dict(
            rule_state=dict(
                type="str", choices=["absent", "present", "add"]
            ),
            variation=dict(type="int"),
            rollout=dict(
                type="dict",
                options=dict(
                    bucket_by=dict(type="str"),
                    weighted_variations=dict(type="list",
                        elements="dict",
                        options=dict(variation=dict(type="int"), weight=dict(type="int"))
                    ),
                )
            ),
            clauses=clause_argument_spec(),
        ),
    )