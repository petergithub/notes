# Project Notes

[TOC]

## Project management

### Document management
Folder structure:
```
AppName Template
├── Digital-Final
│   ├── 01 Project Management
│   ├── 02 Requirements
│   ├── 03 Design
│   ├── 04 Build
│   ├── 05 Test
│   ├── 06 Deploy
│   ├── 07 Support
│   ├── Archive
│   │   ├── 01 Requirements
│   │   ├── 02 Design
│   │   └── 03 Build
│   └── ELC Documentation
│       ├── 01 Requirements Stage
│       ├── 02 Design Stage
│       ├── 03 Build Stage
│       ├── 04 Test Stage
│       └── 05 Deploy Stage
├── Ephotocopy
└── Working
```

### Project lesson learned session
#### Participants
#### Rules
- Focus on process, not people
- Communicate honestly but respectfully
- Curb defensiveness
- Leave Nothing Unsaid (Do not take anything personal)

#### Project Description & Benefits

#### Guiding Topics
We’ll recount the project by SDLC phases:
- Requirements
- Design
- Build
- Test
- Deploy
- Support

For each phase, we’ll use the STOP / START / CONTINUE method to guide our lessons learned discussion:
1. What did not work well?      = Things we should `STOP` doing
2. What did we miss? 	      = Things we should `START` doing
3. What worked well? 	      = Things we should `CONTINUE` doing

#### Example: Project Lessons Learned Session
##### Requirements
1. What did not work well (STOP)?
 - Requirements may be a higher level than should be (should we document details in solution/design level ?)
 - Classification of requirements may not reflect real business needs
 - Taking on too much object level changes

2. What did we miss (START)?
 - Start review of requirements sooner
 - Consider separate work stream for data remediation
 - Good understanding of Integrating Systems

3. What did work well (CONTINUE)?
 - Holistic review of requirements
 - Assess validity of each requirement

4. Others

##### Design
1. What did not work well (STOP)?
2. What did we miss (START)?
3. What did work well (CONTINUE)?

##### Build
1. What did not work well (STOP)?
 - Did not plan well for use of test/training environments
 - Performance of Test environments lacking

2. What did we miss (START)?
 - Plan for necessary environments at the beginning of the project so that they are available for use when needed (parallel development, demos, testing, training etc.)
 - Management of the above environments during use (version, known issues, log etc.)

3. What did work well (CONTINUE)?
 - Build out of automated tasks helped streamline development/deployment

##### Test
##### Deploy
##### Support

## Design
返回list时带上下一条ID, 然后请求数据时带上ID 查询用ID做条件减少翻页

## Process
### Handover process 
Project Management
	1. 有几个功能模块
	2. 已有用户,主要用户联系人
	3. 目前的困难
	4. 未来的发展计划
Requirement
	包括哪些主要功能?
Design
	相关设计文档
Build
	1. 开发环境:本地可以直接连的
Test
	1. 如何测试
Deploy
	1. 几个环境需要部署 各部署的哪个分支
	2. 部署步骤
Support
	1. 新接一个应用的接入步骤
	2. 已知问题
