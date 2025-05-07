# Partially generated with assistance from a large language model trained by Google.

package main.eval

# concat(".", ["data", data.main.data.bundles[_].bundle_id])

# Main evaluation rule to generate the desired "evaluation" output object
evaluation := {
    "rules": collected_deny_results(data.mequal),
}

# Collect all "deny" messages
collected_deny_results(policy_bundle) := [transformed_item |
    walk(policy_bundle, [path, node_value])
    path[count(path)-1] == "deny"
    message_object := node_value[_]
    is_object(message_object)
    parsed_code := split_code_string(message_object.code)
    policy_details := find_policy_metadata(parsed_code.policy_path, data.main.data.bundles)
    transformed_item := {
        "message": message_object.msg,
        "bundle_id": policy_details.bundle_id,
        "policy_id": policy_details.policy_id,
        "rule_id": parsed_code.rule_id,
        "policy_severity": policy_details.policy_severity,
        "rule_severity": policy_details.rule_severity,
        "policy_level": policy_details.policy_level,
        "rule_level": policy_details.rule_level,
        "extra": object.get( message_object, "extra", {})
    }
]

# --- Helper functions ---

# Helper to split a "code" string (e.g., "policy.path.part.rule_id")
# into its constituent policy_path and rule_id parts.
split_code_string(code_str) := result if {
    parts := split(code_str, ".")
    count(parts) >= 2 # Ensure at least a path part and a rule ID part

    rule_id := parts[count(parts) - 1] # The last part is the rule_id
    # All parts except the last one form the policy_path
    policy_path_parts := array.slice(parts, 0, count(parts) - 1)
    policy_path := concat(".", policy_path_parts)

    result := {
        "policy_path": policy_path,
        "rule_id": rule_id
    }
}

# Helper to find bundle_id, policy_id, and policy_severity
# from the `all_bundles` data (data.main.data.bundles) using the `target_policy_path`.
find_policy_metadata(target_policy_path, all_bundles) := metadata if {
    # 'all_bundles' is expected to be the array from data.main.data.bundles
    # Ensure 'all_bundles' is actually an array before trying to index it.
    # This check can be added here or rely on correct data loading.
    # For simplicity, assuming all_bundles is correctly loaded as an array.
    some i, j, k # Quantifiers for iterating through bundles and policies
    bundle := all_bundles[i]
    policy := bundle.policies[j]
    rule := bundle.policies[j].rules[k]
    policy.policy_path == concat(".", ["data", target_policy_path]) # Match the policy_path
    metadata := {
        "bundle_id": bundle.bundle_id,
        "policy_id": policy.policy_id,
        "policy_severity": policy.policy_severity, # This comes from your data.json's policy_severity
        "rule_severity": rule.rule_severity,
        "policy_level": policy.policy_level,
        "rule_level": rule.rule_level
    }
}

# Helper function to check if a policy_path exists in the metadata.
# Used by the fallback rule for find_policy_metadata.
policy_path_exists(target_policy_path, all_bundles) if {
    some i, j
    bundle := all_bundles[i]
    policy := bundle.policies[j]
    policy.policy_path == target_policy_path
}

