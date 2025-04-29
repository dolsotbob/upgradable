import { ethers } from 'hardhat';
import { makeAbi } from './makeABI';

async function main() {
  const Proxy = await ethers.getContractFactory('Proxy');
  const V1 = await ethers.getContractFactory('V1');

  console.log('Deploying Contract...');

  // Todo: 아래에 Proxy 컨트랙트와 V1 컨트랙트가 배포될 수 있도록 script를 완성시켜 주세요.
  const v1 = await V1.deploy();
  await v1.waitForDeployment();

  const proxy = await Proxy.deploy(v1.target);
  await proxy.waitForDeployment();

  // 아래 주의 깊게 보기 
  /* setting */
  console.log('Contract deployed to:', proxy.target);
  await makeAbi('Proxy', `${proxy.target}`);

  console.log('\nContract deployed to:', v1.target);
  await makeAbi('V1', `${proxy.target}`);  // address를 proxy address를 준다 
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
