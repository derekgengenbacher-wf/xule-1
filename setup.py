from setuptools import setup, find_packages

setup(
    name='w_versioned_xule',
    version='@VERSION@',
    description='The XBRL.US plugin for data quality',
    long_description=open('README.md').read(),
    url='https://github.com/workiva/xule',
    author='Workiva',
    author_email='dave.casleton@workiva.com',
    include_package_data=True,
    packages=find_packages(),
    classifiers=[
        'License :: OSI Approved :: Apache License, Version 2.0 (Apache-2.0)',
        'Copyright :: American Institute of CPAs (AICPA) :: 2019',
        'Copyright :: Calcbench, Inc. :: 2019',
        'Copyright :: Merrill Communications LLC :: 2019',
        'Copyright :: Vintage, a division of PR Newswire :: 2019',
        'Copyright :: Workiva Inc. :: 2019',
        'Copyright :: XBRL US, Inc. :: 2019',
        'Programming Language :: Python :: 3.6',
    ],
    install_requires=[
        'aniso8601==3.0.2'
    ],
)
