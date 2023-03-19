# devimage

This repository provides a Docker image intended to be used as a base image for development in [devcontainers](https://code.visualstudio.com/docs/remote/containers). It includes multiple programming languages and tools pre-installed using the [asdf](https://asdf-vm.com) version manager, allowing you to switch between different versions of languages and tools.

## Table of Contents

- [Supported Languages](#supported-languages)
- [Supported Tools](#supported-tools)
- [Usage](#usage)
- [Environment Variables](#environment-variables)
- [Customization](#customization)

## Supported Languages

The following programming languages are supported:

- Python
- Ruby
- Golang
- Node.js

## Supported Tools

The following tools are supported:

- Yarn
- Task
- Direnv
- Github CLI

## Usage

To use this image as the base for your own devcontainer, create a `.devcontainer` folder in your project's root directory, and create a `devcontainer.json` file within that folder with the following content:

```json
{
  "name": "Your Dev Container Name",
  "image": "gchr.io/devtemplates/devimage"
}
```

You can customize the devcontainer.json file according to your project's requirements.

### Environment Variables

You can configure the Docker image at runtime by passing environment variables. The following environment variables are supported:

- `PYTHON_VERSION`
- `RUBY_VERSION`
- `GOLANG_VERSION`
- `NODEJS_VERSION`

To pass an environment variable, add it to the runArgs array in your devcontainer.json file, like this:

```json
"runArgs": [
  "--env", "PYTHON_VERSION=3.11.2"
]
```

## Customization

The image can be further customized by extending the provided Dockerfile. Add additional dependencies, languages, and tools as needed.

For example, to add support for PHP, you could include the following lines in your custom Dockerfile:

```Dockerfile
RUN asdf plugin add php
RUN asdf install php <desired-version>
RUN asdf global php <desired-version>
```

Replace <desired-version> with the PHP version you want to use.

## License

The MIT License (MIT) Copyright (c) Jarid Margolin

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
