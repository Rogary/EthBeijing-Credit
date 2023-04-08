import React, { useMemo, useState } from "react";
import { ethers } from "ethers";
import { isArray } from "lodash-es";
import { motion } from "framer-motion";
import * as echarts from "echarts";
import { LeftOutlined } from "@ant-design/icons";
import { ConfigProvider, theme, Button, message } from "antd";
import dayjs from "dayjs";
import CountUp from "react-countup";

const ALCHEMY_ID = "DoR8M9zv6xUfIklZM1sPCiCeelsSZ_t9";
const alchemyURL = `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_ID}`;

// 0x7cF9079AB6FA05b0Abbaa410EfC3CEEaA66350fb

import creditAbi from "@src/abi/credit.json";

import copper from "@src/assets/img/copper.png";
import silver from "@src/assets/img/silver.png";
import gold from "@src/assets/img/gold.png";
import king from "@src/assets/img/king.png";

const CREDIT_ADDRESS = "0x186CFf323D61b839Aebe897310f3f1310bfAF183";

interface InteCompositions {
  name: string;
  max: number;
  grade: number;
}

interface InteUserScore {
  grade: number;
  compositions: InteCompositions[];
}

interface InteUserInfo {
  avatarUrl: string;
  updateTime: string;
}

const latitudeNameList: string[] = [
  "OPH",
  "OCH",
  "INFT",
  "LAC",
  "OEC",
  "SCS",
  "DCS",
  "OAH",
];

const Popup: React.FC = () => {
  const [walletAddress, setWalletAddress] = useState<string>("");
  const [isShowScore, setIsShowScore] = useState<boolean>(false);
  const [userScore, setUserScore] = useState<number>(0);
  const [messageApi, contextHolder] = message.useMessage();
  const [userInfo, setUserInfo] = useState<InteUserInfo>({
    avatarUrl: "",
    updateTime: "",
  });

  const badgeInfo: {
    level: string;
    url: string;
  } = useMemo(() => {
    if (userScore < 320) {
      return {
        level: "青 铜",
        url: copper,
      };
    }
    if (userScore < 480) {
      return {
        level: "白 银",
        url: silver,
      };
    }
    if (userScore < 640) {
      return {
        level: "黄 金",
        url: gold,
      };
    }
    return {
      url: king,
      level: "王 者",
    };
  }, [userScore]);

  const handleSorce = async () => {
    const provider = new ethers.providers.JsonRpcProvider(alchemyURL);
    const creditContract = new ethers.Contract(
      CREDIT_ADDRESS,
      creditAbi,
      provider
    );
    messageApi.loading({ content: "正在计算中，请稍后...", duration: 2000 });

    const tx = await creditContract.getGrade(walletAddress);
    console.log("tx: ", tx);
    messageApi.destroy();
    setIsShowScore(true);

    const {
      _,
      1: latitudeScoreList,
      2: latitudeMaxScoreList,
      lastUpdateTime,
    } = tx;
    if (
      isArray(latitudeScoreList) &&
      isArray(latitudeMaxScoreList) &&
      isArray(tx.realTimeGrade)
    ) {
      const [realTimeMaxScore, realTimeScore] = tx.realTimeGrade;

      const realTime: InteCompositions = {
        name: latitudeNameList.pop() as string,
        max: ethers.BigNumber.from(realTimeMaxScore).toNumber(),
        grade: ethers.BigNumber.from(realTimeScore).toNumber(),
      };

      const sum = latitudeScoreList
        .reduce(
          (acc, cur) => acc.add(ethers.BigNumber.from(cur)),
          ethers.BigNumber.from(0)
        )
        .add(ethers.BigNumber.from(realTimeScore));

      const upChainScore: InteUserScore = {
        grade: sum.toNumber(),
        compositions: latitudeScoreList.map((item, index) => {
          return {
            name: latitudeNameList[index],
            max: latitudeMaxScoreList[index].toNumber(),
            grade: item.toNumber(),
          };
        }),
      };

      upChainScore.compositions.push(realTime);
      setUserScore(sum.toNumber());
      handleChartOption(upChainScore);

      setUserInfo({
        ...userInfo,
        updateTime:
          lastUpdateTime.toNumber() === 0
            ? ""
            : dayjs.unix(lastUpdateTime.toNumber()).format("YYYY-MM-DD"),
      });
    } else {
      handleChartOption({
        grade: 0,
        compositions: latitudeNameList.map((item, index) => {
          return {
            name: latitudeNameList[index],
            max: latitudeMaxScoreList[index].toNumber(),
            grade: 0,
          };
        }),
      });
    }
  };

  const handleBack = () => {
    setIsShowScore(!isShowScore);
    setWalletAddress("");
  };

  const handleChartOption = ({ compositions }: InteUserScore) => {
    setTimeout(() => {
      const chart = echarts.init(
        document.getElementById("chart") as HTMLDivElement
      );
      console.log("chart: ", chart);
      chart.setOption({
        tooltip: {
          trigger: "axis",
          backgroundColor: "rgba(0,0,0,0.7)",
          color: "black",
          textStyle: {
            color: "white", //设置文字颜色
          },
        },
        radar: [
          {
            indicator: compositions.map(({ name, max }) => {
              return {
                name,
                max,
              };
            }),
            center: ["50%", "50%"],
            splitLine: {
              show: true,
              lineStyle: {
                width: 1,
                color: "white", // 图表背景网格线的颜色
              },
            },
          },
        ],
        series: [
          {
            type: "radar",
            itemStyle: { color: "#9974ee" },
            areaStyle: {
              color: "#d946ef",
              borderColor: "#d946ef",
            },
            data: [
              {
                value: compositions.map(({ grade }) => grade),
                name: "各项分值",
              },
            ],
          },
        ],
      });
    });
  };

  return (
    <ConfigProvider theme={{ algorithm: theme.darkAlgorithm }}>
      {contextHolder}
      <section className="w-screen h-[480px] overflow-hidden relative">
        <section className="w-full h-full relative z-10 flex items-center justify-center">
          {!isShowScore ? (
            <section className="w-11/12 flex flex-col items-center">
              <input
                value={walletAddress}
                className="focus:ring-2 focus:ring-fuchsia-500 focus:outline-none bg-transparent appearance-none w-full text-sm leading-6 placeholder-white rounded-md py-2 px-4 ring-1 ring-slate-200 shadow-sm text-white"
                type="text"
                aria-label="Wallet Address"
                placeholder="Wallet Address"
                onChange={(e) => setWalletAddress(e.target.value)}
              />

              <button
                onClick={handleSorce}
                className="bg-gradient-to-r text-white from-violet-500 to-fuchsia-500 w-[180px] h-[40px] rounded-xl mt-10 shadow-inner hover:scale-105 transition-[transform]"
              >
                获 取 信 用 分
              </button>
            </section>
          ) : (
            <section className="w-full h-full flex flex-col items-center pt-3 pb-2 px-4">
              <section className="w-full flex justify-start items-center text-white">
                <Button
                  className="flex items-center justify-center justify-self-start"
                  type="text"
                  icon={<LeftOutlined />}
                  onClick={handleBack}
                />
                <section className="mx-auto flex items-center">
                  <span className="text-xl mr-4">信用分:</span>
                  <CountUp className="text-3xl" end={userScore} />
                </section>
              </section>

              <section id="chart" className="w-[230px] h-[280px]"></section>
              <section className="text-white w-full text-right mx-3">
                {userInfo.updateTime ? (
                  <span className="text-sm">
                    上次更新时间: {userInfo.updateTime}
                  </span>
                ) : null}
              </section>

              <section className="flex items-center">
                <motion.div
                  animate={{
                    scale: [1.1, 1.04, 1.1],
                    transition: {
                      ease: "linear",
                      duration: 2,
                      repeat: Infinity,
                    },
                  }}
                >
                  <img
                    className="scale-110"
                    src={badgeInfo.url}
                    alt="badge"
                    width={120}
                  />
                </motion.div>
                <p className="text-white text-center w-[210px]">
                  <span className="text-base">信用等级 : </span>
                  <span className="text-lg">{badgeInfo.level}</span>
                </p>
              </section>
            </section>
          )}
        </section>

        <iframe
          className="absolute top-0 left-0"
          style={{ width: "100vw", height: "100vh" }}
          src="https://canvas.tutulist.cn/"
        />
      </section>
    </ConfigProvider>
  );
};

export default Popup;
