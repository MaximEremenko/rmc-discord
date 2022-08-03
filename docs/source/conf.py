# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
import sys
sys.path.insert(0, os.path.abspath('../../disorder/'))


# -- Project information -----------------------------------------------------

project = 'rmc-discord'
copyright = 'Zachary Morgan'
author = 'Zachary Morgan'

# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinx.ext.githubpages',
    'sphinx.ext.autodoc',
    'sphinx.ext.linkcode',
    'sphinx.ext.extlinks',
    'sphinx.ext.intersphinx',
    'sphinx.ext.mathjax',
    'sphinx.ext.todo',
    'numpydoc',
]
# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []

master_doc = 'index'

# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'pydata_sphinx_theme'
html_permalinks_icon = '#'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named 'default.css' will overwrite the builtin 'default.css'.
html_static_path = ['_static']

html_theme_options = {
    'logo': {
        'image_light': 'logo-light.svg',
        'image_dark': 'logo-dark.svg',
        'link': 'https://zjmorgan.github.io/rmc-discord/',
    },
    'icon_links': [
        {
            'name': 'GitHub',
            'url': 'https://github.com/zjmorgan/rmc-discord',
            'icon': 'fab fa-github-square',
            'type': 'fontawesome',
        },
        {
            'name': 'rmc-discord',
            'url': 'https://zjmorgan.github.io/rmc-discord/',
            'icon': '_static/icon.svg',
            'type': 'local',
        },
    ],
    'external_links': [
        {
            'url': 'https://pypi.org/project/rmc-discord/',
            'name': 'PyPI',
        },
    ],
    'show_nav_level': 2,
}

# -- Extension configuration -------------------------------------------------

add_module_names = False

def linkcode_resolve(domain, info):
    if domain != 'py':
        return None
    if not info['module']:
        return None
    filename = info['module'].replace('.', '/')
    return "https://github.com/zjmorgan/rmc-discord/blob/master/%s.py" % filename