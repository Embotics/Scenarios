import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="rivermeadow",
    version="0.0.1",
    author="rmartens",
    author_email="rmartens@embotics.com",
    description="RiverMeadow API client",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="http://svrrepo.embotics.com/rmartens/rivermeadow",
    install_requires=['requests'],
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
)