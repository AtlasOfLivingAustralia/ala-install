#!/usr/bin/python
# -*- coding: utf-8 -*-

from ansible.errors import AnsibleError
from packaging import version as pkg_version

def determine_java_version(service_name, service_version, dependencies_dict):
    """
    Determine Java version from LA Toolkit dependencies.yaml

    Args:
        service_name: Name of the service (e.g., 'collectory', 'species-lists')
        service_version: Version of the service (e.g., '6.0.0', 'develop')
        dependencies_dict: Parsed dependencies.yaml as dict

    Returns:
        Java version as string (e.g., '17', '11', '8')
    """

    # Default to Java 17 if not found
    default_java = '17'

    # Get service dependencies
    service_deps = dependencies_dict.get(service_name, {})

    if not service_deps:
        return default_java

    # Track the highest Java version found for 'develop'
    highest_java = None
    matched_java = None

    # Iterate through constraints
    for constraint, requirements in service_deps.items():
        if not isinstance(requirements, list):
            continue

        # Extract java version from requirements (which is a list of dicts)
        java_ver = None
        for req in requirements:
            if isinstance(req, dict) and 'java' in req:
                java_ver = str(req['java']).strip()
                break

        if not java_ver:
            continue

        # Track highest Java version for develop
        if highest_java is None or int(java_ver) > int(highest_java):
            highest_java = java_ver

        # For 'develop', use highest Java version
        if service_version == 'develop':
            continue

        # Parse constraint and check if version matches
        try:
            if matches_constraint(service_version, constraint):
                matched_java = java_ver
                # Don't break - keep checking in case there's a more specific match
        except Exception:
            pass

    # Return matched version or highest for develop
    if service_version == 'develop':
        return highest_java if highest_java else default_java

    return matched_java if matched_java else default_java


def matches_constraint(version_str, constraint_str):
    """
    Check if a version matches a constraint.

    Supports:
    - '>= 3.1.0 < 6.0.0'
    - '>= 6.0.0'
    - '< 3.1.0'
    - '>= 6.5.6-3'  (with pre-release)
    """

    version_str = str(version_str).strip()
    constraint_str = str(constraint_str).strip()

    # Parse version
    try:
        ver = pkg_version.parse(version_str)
    except Exception:
        return False

    # Handle combined constraints like '>= 3.1.0 < 6.0.0'
    parts = constraint_str.split()

    i = 0
    all_match = True

    while i < len(parts):
        operator = None
        target = None

        # Parse operator and version
        if parts[i].startswith('>='):
            operator = '>='
            target_str = parts[i][2:].strip()
            if target_str:
                target = target_str
            elif i + 1 < len(parts):
                target = parts[i + 1]
                i += 1
        elif parts[i].startswith('<='):
            operator = '<='
            target_str = parts[i][2:].strip()
            if target_str:
                target = target_str
            elif i + 1 < len(parts):
                target = parts[i + 1]
                i += 1
        elif parts[i].startswith('>'):
            operator = '>'
            target_str = parts[i][1:].strip()
            if target_str:
                target = target_str
            elif i + 1 < len(parts):
                target = parts[i + 1]
                i += 1
        elif parts[i].startswith('<'):
            operator = '<'
            target_str = parts[i][1:].strip()
            if target_str:
                target = target_str
            elif i + 1 < len(parts):
                target = parts[i + 1]
                i += 1
        elif parts[i] in ['>=', '<=', '>', '<']:
            operator = parts[i]
            if i + 1 < len(parts):
                target = parts[i + 1]
                i += 1

        if operator and target:
            try:
                target_ver = pkg_version.parse(target)

                # Check constraint
                if operator == '>=' and not (ver >= target_ver):
                    all_match = False
                    break
                elif operator == '<=' and not (ver <= target_ver):
                    all_match = False
                    break
                elif operator == '>' and not (ver > target_ver):
                    all_match = False
                    break
                elif operator == '<' and not (ver < target_ver):
                    all_match = False
                    break
            except Exception:
                return False

        i += 1

    return all_match


class FilterModule(object):
    """Ansible filter plugin for determining Java versions"""

    def filters(self):
        return {
            'determine_java_version': determine_java_version
        }

